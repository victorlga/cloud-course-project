#resource "aws_instance" "ec2" {
#  ami                         = var.ami
#  instance_type               = var.instance_type
#  subnet_id                   = var.public_subnet_id
#  vpc_security_group_ids      = [var.ec2_sg_id]
#  associate_public_ip_address = true
#  key_name                    = aws_key_pair.deployer.key_name
#
#  user_data = <<-EOF
#              #!/bin/bash -ex
#              amazon-linux-extras install nginx1 -y
#              echo "<h1>$(curl https://api.kanye.rest/?format=text)</h1>" >  /usr/share/nginx/html/index.html 
#              systemctl enable nginx
#              systemctl start nginx
#              EOF
#
#  tags = {
#    "Name" : "Kanye"
#  }
#}
#
#resource "aws_key_pair" "deployer" {
#  key_name   = "deployer-key"
#  public_key = file(var.PATH_TO_YOUR_PUBLIC_KEY)
#}
#


#user_data = <<-EOF
  #            #!/bin/bash
  #            sudo apt-get update
  #            sudo apt-get install -y python3-pip git
  #            git clone https://github.com/victorlga/lightweight_baby.git /home/ubuntu/fastapi-app
  #            cd /home/ubuntu/fastapi-app
  #            pip3 install -r docs/requirements.txt
  #            export DATABASE_USER=${var.database_user}
  #            export DATABASE_PASS=${var.database_pass}
  #            export DATABASE_HOST=${var.database_host}
  #            export DATABASE_PORT=${var.database_port}
  #            export DATABASE_NAME=${var.database_name}
  #            sudo uvicorn sql_app.main:app --reload --port 80
  #            EOF


resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = [var.public_sub_1_id, var.public_sub_2_id]

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
  name_prefix   = "lt-"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer.key_name

  user_data = base64encode(<<-EOF
                #!/bin/bash
                sudo apt-get update
                sudo apt-get install nginx -y
                sudo mkdir -p /var/www/html
                echo '<h1>Hello, World!</h1>' | sudo tee /var/www/html/index.html
                systemctl enable nginx
                systemctl start nginx
                EOF
  )

  vpc_security_group_ids = [var.ec2_sg_id]
}

resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier  = [var.private_sub_1_id, var.private_sub_2_id]
  max_size             = 5
  min_size             = 1
  desired_capacity     = 4
  health_check_type    = "EC2"
  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  target_group_arns    = [aws_lb_target_group.my_tg.arn]

  tag {
    key                 = "Name"
    value               = "ASG-Instance"
    propagate_at_launch = true
  }
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