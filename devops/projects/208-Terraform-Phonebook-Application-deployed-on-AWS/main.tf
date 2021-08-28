terraform {
  required_version = "~> 0.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.44.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
}

resource "aws_vpc" "prod-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  instance_tenancy     = "default"

  tags = {
    Name = "prod-vpc"
  }
}

resource "aws_subnet" "prod-subnet-public-1" {
  vpc_id                  = aws_vpc.prod-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true" //it makes this a public subnet
  availability_zone       = "us-east-1a"

  tags = {
    Name = "prod-subnet-public-1"
  }
}
resource "aws_subnet" "prod-subnet-public-2" {
  vpc_id                  = aws_vpc.prod-vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = "true" //it makes this a public subnet
  availability_zone       = "us-east-1b"

  tags = {
    Name = "prod-subnet-public-1"
  }
}
resource "aws_subnet" "prod-subnet-private-1" {
  vpc_id                  = aws_vpc.prod-vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "false" //it makes this a privatesubnet
  availability_zone       = "us-east-1a"

  tags = {
    Name = "prod-subnet-private-1"
  }
}

resource "aws_subnet" "prod-subnet-private-2" {
  vpc_id                  = aws_vpc.prod-vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = "false" //it makes this a privatesubnet
  availability_zone       = "us-east-1b"

  tags = {
    Name = "prod-subnet-private-2"
  }
}


# create an IGW (Internet Gateway)
# It enables your vpc to connect to the internet
resource "aws_internet_gateway" "prod-igw" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "prod-igw"
  }
}

# create a custom route table for public subnets
# public subnets can reach to the internet buy using this
resource "aws_route_table" "prod-public-crt" {
  vpc_id = aws_vpc.prod-vpc.id
  route {
    cidr_block = "0.0.0.0/0"                      //associated subnet can reach everywhere
    gateway_id = aws_internet_gateway.prod-igw.id //CRT uses this IGW to reach internet
  }

  tags = {
    Name = "prod-public-crt"
  }
}

resource "aws_route_table" "prod-private-crt" {
  vpc_id = aws_vpc.prod-vpc.id
  tags = {
    Name = "prod-private-crt"
  }
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.prod-private-crt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# route table association for the public subnets
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.prod-subnet-public-1.id
  route_table_id = aws_route_table.prod-public-crt.id
}
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.prod-subnet-public-2.id
  route_table_id = aws_route_table.prod-public-crt.id
}
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.prod-subnet-private-1.id
  route_table_id = aws_route_table.prod-private-crt.id
}
resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.prod-subnet-private-2.id
  route_table_id = aws_route_table.prod-private-crt.id

}
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = element(aws_subnet.prod-subnet-public-1.*.id, 0)
  depends_on    = [aws_internet_gateway.prod-igw]
}

resource "aws_security_group" "server-sg" {
  name   = "WebServerSecurityGroup"
  vpc_id = aws_vpc.prod-vpc.id
  tags = {
    "Name" = "TF_WebServerSecurityGroup"
  }
  ingress {
    from_port       = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-sg.id]
    to_port         = 80
  }
  ingress {
    from_port   = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 22
  }
  egress {
    from_port   = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 0
  }
}
resource "aws_security_group" "alb-sg" {
  name   = "ALBSecurityGroup"
  vpc_id = aws_vpc.prod-vpc.id
  tags = {
    "Name" = "TF_ALBSecurityGroup"
  }
  ingress {
    from_port   = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 443
  }
  ingress {
    from_port   = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 80
  }
  egress {
    from_port   = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 0
  }
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_key_pair" "my-key-pair" {
  key_name   = "id_rsa"
  public_key = file(var.PUBLIC_KEY_PATH)
}
resource "aws_launch_template" "asg-lt" {
  name                   = "phonebook-lt"
  image_id               = data.aws_ami.amazon-linux-2.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.my-key-pair.id
  vpc_security_group_ids = [aws_security_group.server-sg.id]
  user_data              = base64encode(data.template_file.elkscript.rendered)
  tag_specifications {
    resource_type = "instance"
    tags = {
      "Name" = "Web Server of Phonebook App"
    }
  }
}

data "template_file" "elkscript" {
  template = file("./userdata.sh")
  vars = {
    MyDBURI = "${aws_db_instance.db-server.address}"
  }
}
resource "aws_alb_target_group" "app-lb-tg" {
  name        = "phonebook-lb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.prod-vpc.id
  target_type = "instance"
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}
resource "aws_alb" "app-lb" {
  name               = "phonebook-lb-tf"
  ip_address_type    = "ipv4"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = ["${aws_subnet.prod-subnet-public-1.id}", "${aws_subnet.prod-subnet-public-2.id}"]
}

resource "aws_lb_listener" "front_end-https" {
  load_balancer_arn = aws_alb.app-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.ssl_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app-lb-tg.arn
  }
}

resource "aws_lb_listener" "front_end-http" {
  load_balancer_arn = aws_alb.app-lb.arn
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
resource "aws_autoscaling_group" "app-asg" {
  name                      = "phonebook-asg"
  desired_capacity          = 2
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  target_group_arns         = [aws_alb_target_group.app-lb-tg.arn]
  vpc_zone_identifier       = ["${aws_subnet.prod-subnet-private-1.id}", "${aws_subnet.prod-subnet-private-2.id}"]
  launch_template {
    id      = aws_launch_template.asg-lt.id
    version = aws_launch_template.asg-lt.latest_version
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.prod-subnet-private-1.id, aws_subnet.prod-subnet-private-2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_security_group" "db-sg" {
  name   = "RDSSecurityGroup"
  vpc_id = aws_vpc.prod-vpc.id
  tags = {
    "Name" = "TF_RDSSecurityGroup"
  }
  ingress {
    from_port       = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.server-sg.id]
    to_port         = 3306
  }
  egress {
    from_port   = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 0
  }
}

resource "aws_db_instance" "db-server" {
  instance_class              = "db.t2.micro"
  allocated_storage           = 20
  vpc_security_group_ids      = ["${aws_security_group.db-sg.id}"]
  db_subnet_group_name        = aws_db_subnet_group.default.name
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  backup_retention_period     = 0
  identifier                  = "phonebook-app-db"
  name                        = var.dbname
  engine                      = "mysql"
  engine_version              = "8.0.20"
  username                    = var.dbuser
  password                    = var.dbpassword
  multi_az                    = false
  port                        = 3306
  publicly_accessible         = false
  skip_final_snapshot         = true
  monitoring_interval         = 0
}

data "aws_route53_zone" "aws_capstone_zone" {
  name = var.domain_name
}
data "aws_elb_hosted_zone_id" "main" {}

resource "aws_route53_record" "web_domain" {
  zone_id         = var.zone_id
  name            = join("", ["${var.cname}.","${data.aws_route53_zone.aws_capstone_zone.name}"])
  type            = "A"
  alias {
    name                   = aws_alb.app-lb.dns_name
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.ssl_certificate.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = "${var.zone_id}"
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

# SSL Certificate
resource "aws_acm_certificate" "ssl_certificate" {
  provider                  = aws.acm_provider
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  #validation_method         = "EMAIL"
  validation_method = "DNS"
  tags = {
    Name = "mehmetafsar.com"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Uncomment the validation_record_fqdns line if you do DNS validation instead of Email.
resource "aws_acm_certificate_validation" "cert_validation" {
  provider                = aws.acm_provider
  certificate_arn         = aws_acm_certificate.ssl_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}