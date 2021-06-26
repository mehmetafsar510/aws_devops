#------ elb-asg/main.tf ---

resource "aws_lb" "aws_capstone_alb" {
  name               = "aws-capstone-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [var.alb_sg]

}

resource "aws_lb_target_group" "aws_capstone_tg" {
  name     = "aws-capstone-alb-tg-${substr(uuid(), 0, 3)}"
  port     = var.tg_port #80
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
  health_check {
    healthy_threshold   = var.lb_healthy_threshold
    unhealthy_threshold = var.lb_unhealthy_threshold
    timeout             = var.lb_timeout
    interval            = var.lb_interval
  }
}

resource "aws_lb_listener" "aws_capstone_alb_listener_1" {
  load_balancer_arn = aws_lb.aws_capstone_alb.arn
  protocol          = "HTTP"
  port              = "80"
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "aws_capstone_alb_listener_2" {
  load_balancer_arn = aws_lb.aws_capstone_alb.arn
  protocol          = "HTTPS"
  port              = "443"
  certificate_arn   = var.certificate_arn_elb
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws_capstone_tg.arn

  }
}

resource "aws_autoscaling_policy" "aws_capstone_asg_policy" {
  name                   = "aws-capstone-asg-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.aws_capstone_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 80.0
  }
}

resource "aws_autoscaling_group" "aws_capstone_asg" {
  name                      = "aws-capstone-asg"
  desired_capacity          = 2
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  target_group_arns         = [aws_lb_target_group.aws_capstone_tg.arn]
  vpc_zone_identifier       = var.private_subnets
  launch_template {
    id      = var.launch_template_id
    version = var.launch_template_latest_version
  }
}