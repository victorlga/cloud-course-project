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
    path                = "/docs"
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

resource "aws_launch_template" "lt" {
  name_prefix            = "lt-"
  image_id               = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.ec2_sg_id]

  user_data = base64encode(templatefile("${path.module}/user_data.tftpl", {
    db_host = var.db_host
  }))

  iam_instance_profile {
    name = var.ec2_profile_name
  }

}


resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier  = [var.private_sub_1_id, var.private_sub_2_id]
  max_size             = 5
  min_size             = 2
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
  period              = "10"
  statistic           = "Average"
  threshold           = "20"
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
  cooldown               = 10
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "low-cpu-usage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "10"
  statistic           = "Average"
  threshold           = "10"
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
  cooldown               = 10
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_cloudwatch_log_group" "my_log_group" {
  name = "/my-fastapi-app/logs"
}

resource "aws_autoscaling_policy" "scale_up_down_tracking" {
  policy_type            = "TargetTrackingScaling"
  name                   = "scale-up-down-tracking"
  autoscaling_group_name = aws_autoscaling_group.asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label = "${split("/", aws_lb.my_alb.id)[1]}/${split("/", aws_lb.my_alb.id)[2]}/${split("/", aws_lb.my_alb.id)[3]}/targetgroup/${split("/", aws_lb_target_group.my_tg.arn)[1]}/${split("/", aws_lb_target_group.my_tg.arn)[2]}"
    }
    target_value = 300
  }

  lifecycle {
    create_before_destroy = true 
  }
}


