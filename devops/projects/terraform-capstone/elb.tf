
resource "aws_iam_role" "ec2_role" {
  name = "test_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "S3Full-access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_instance_profile" "my_profile" {
  name = "my_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_launch_template" "foo" {
  name = "foo"
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 8
    }
  }
  iam_instance_profile {
    arn = aws_iam_instance_profile.my_profile.arn
  }
  instance_type = "t2.micro"
  image_id      = lookup(var.AMI, var.AWS_REGION)
  key_name      = "the_doctor"

  monitoring {
    enabled = true
  }

  vpc_security_group_ids = ["${aws_security_group.WebServersSecGroup.id}"]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "capstone"
    }
  }

  user_data = base64encode(data.template_file.elkscript.rendered)
}

data "template_file" "elkscript" {
  template = file("./templates/userdata.sh")
  vars = {
    rds_endpoint = "${aws_db_instance.default.address}"
    BucketName   = "${var.bucket_name}"
    DBPassword   = "${var.database_password}"
  }
}

resource "aws_lb" "front_end" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.ALBSecurityGroup.id}"]
  subnets            = ["${aws_subnet.prod-subnet-public-1.id}", "${aws_subnet.prod-subnet-public-2.id}"]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "front_end" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.prod-vpc.id
}


resource "aws_lb_listener" "front_end-https" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.ssl_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}


resource "aws_lb_listener" "front_end-http" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_autoscaling_group" "bar" {
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 1
  health_check_type         = "ELB"
  health_check_grace_period = 300
  force_delete              = true
  target_group_arns         = [aws_lb_target_group.front_end.arn]
  vpc_zone_identifier       = [aws_subnet.prod-subnet-private-1.id, aws_subnet.prod-subnet-private-2.id]

  launch_template {
    id      = aws_launch_template.foo.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "${var.name}-asg"
    propagate_at_launch = true
  }

}

resource "aws_autoscaling_notification" "email_notifications" {
  group_names = [
    aws_autoscaling_group.bar.name
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = aws_sns_topic.email.arn
}

resource "aws_sns_topic" "email" {
  name = "example-topic"

  # arn is an exported attribute
}

resource "aws_autoscaling_policy" "example" {
  name                   = "capstone"
  autoscaling_group_name = aws_autoscaling_group.bar.name
  policy_type            = "TargetTrackingScaling"
  # ... other configuration ...

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
  }
}

output "elb_dnsname" {
  value = join("", ["https://", "${aws_lb.front_end.dns_name}"])
}

output "capstonedomainname" {
  value = join("", ["https://", "terraform.${var.domain_name}"])
}