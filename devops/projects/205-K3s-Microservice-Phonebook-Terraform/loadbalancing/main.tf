# --- loadbalancing/main.tf ---

resource "aws_lb" "mtc_lb" {
  name            = "mtc-loadbalancer"
  subnets         = var.public_subnets
  security_groups = [var.public_sg]
  idle_timeout    = 400
}

resource "aws_lb_target_group" "mtc_tg_1" {
  name     = "mtc-lb-tg-${substr(uuid(), 0, 3)}"
  port     = var.tg_port1
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
  health_check {
    healthy_threshold   = var.elb_healthy_threshold
    unhealthy_threshold = var.elb_unhealthy_threshold
    timeout             = var.elb_timeout
    interval            = var.elb_interval
  }
}

resource "aws_lb_target_group" "mtc_tg_2" {
  name     = "mtc-lb-tg-${substr(uuid(), 0, 3)}"
  port     = var.tg_port2
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
  health_check {
    healthy_threshold   = var.elb_healthy_threshold
    unhealthy_threshold = var.elb_unhealthy_threshold
    timeout             = var.elb_timeout
    interval            = var.elb_interval
  }
}

resource "aws_lb_listener" "aws_capstone_alb_listener_2" {
  load_balancer_arn = aws_lb.mtc_lb.arn
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
resource "aws_lb_listener" "mtc_lb_listener_1" {
  load_balancer_arn = aws_lb.mtc_lb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  certificate_arn   = var.certificate_arn_elb
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mtc_tg_1.arn
  }
}

resource "aws_alb_listener_rule" "listener_rule1" {  
  listener_arn = "${aws_lb_listener.mtc_lb_listener_1.arn}"  
  priority     = "1"   
  action {    
    type             = "forward"    
    target_group_arn = "${aws_lb_target_group.mtc_tg_1.id}"  
  }   
  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

resource "aws_alb_listener_rule" "listener_rule2" {
  listener_arn = "${aws_lb_listener.mtc_lb_listener_1.arn}"  
  priority     = "2"   
  action {    
    type             = "forward"    
    target_group_arn = "${aws_lb_target_group.mtc_tg_2.id}"  
  }   
  condition {
    path_pattern {
      values = ["/choose", "/add", "/delete", "/update"]
    }
  }
}