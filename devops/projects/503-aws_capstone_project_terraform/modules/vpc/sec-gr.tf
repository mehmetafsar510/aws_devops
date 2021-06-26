resource "aws_security_group" "aws_capstone_alb_sg" {
  name        = "aws_capstone_alb_sg"
  description = "aws capstone project alb security group"
  vpc_id      = aws_vpc.aws_capstone_vpc.id
  dynamic "ingress" {
    for_each = var.alb_security_group
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "aws_capstone_alb_sg"
  }
}

resource "aws_security_group" "aws_capstone_ec2_sg" {
  name        = "aws_capstone_ec2_sg"
  description = "aws capstone project ec2 security group"
  vpc_id      = aws_vpc.aws_capstone_vpc.id
  dynamic "ingress" {
    for_each = var.ec2_security_group
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [aws_security_group.aws_capstone_alb_sg.id]
    }
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "aws_capstone_ec2_sg"
  }
}

resource "aws_security_group" "aws_capstone_rds_sg" {
  name        = "aws_capstone_rds_sg"
  description = "aws capstone project rds security group"
  vpc_id      = aws_vpc.aws_capstone_vpc.id
  dynamic "ingress" {
    for_each = var.rds_security_group
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [aws_security_group.aws_capstone_ec2_sg.id]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "aws_capstone_rds_sg"
  }
}

resource "aws_security_group" "aws_capstone_natinstance_sg" {
  name        = "aws_capstone_natinstance_sg"
  description = "aws capstone project nat instance security group"
  vpc_id      = aws_vpc.aws_capstone_vpc.id
  dynamic "ingress" {
    for_each = var.natinstance_security_group
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "aws_capstone_natinstance_sg"
  }
}

