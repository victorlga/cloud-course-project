resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = [var.private_sub_1_id, var.private_sub_2_id]
  
  enable_deletion_protection = false

  tags = {
    Name = "my-alb"
  }
}

resource "aws_lb_target_group" "my_tg" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    port                = "80"
  }

  tags = {
    Name = "my-target-group"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_tg.arn
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file(var.PATH_TO_YOUR_PUBLIC_KEY)
}

resource "aws_launch_template" "lt" {
  name_prefix            = "lt-"
  image_id               = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [var.ec2_sg_id]

  user_data = base64encode(<<-EOF
              #!/bin/bash

              # Update and install required packages
              sudo apt-get update
              sudo apt-get install -y python3-pip python3-venv git authbind

              # Clone the repository
              git clone https://github.com/victorlga/simple_python_crud.git /home/ubuntu/simple_python_crud
              cd /home/ubuntu/simple_python_crud

              # Setup Python virtual environment
              python3 -m venv env
              source env/bin/activate
              pip install -r requirements.txt

              # Export environment variables
              export DB_HOST=10.0.3.146
              export DB_NAME=mysql_db
              export DB_USER=username
              export DB_PASS=super_secret_password

              # Setup authbind for port 80
              sudo touch /etc/authbind/byport/80
              sudo chmod 500 /etc/authbind/byport/80
              sudo chown ubuntu /etc/authbind/byport/80

              # Use authbind to run the application on port 80
              authbind --deep uvicorn main:app --host 0.0.0.0 --port 80
              EOF
  )


}

              


resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier  = [var.public_sub_1_id, var.public_sub_2_id]
  max_size             = 5
  min_size             = 1
  desired_capacity     = 2
  health_check_type    = "EC2"

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  target_group_arns    = [aws_lb_target_group.my_tg.arn]
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This metric monitors ec2 cpu usage"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "low-cpu-usage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "30"
  alarm_description   = "This metric monitors ec2 cpu usage"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}