resource "aws_security_group" "natinstance" {

  vpc_id = aws_vpc.prod-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    // This means, all ip address are allowed to ssh !
    // Do not do it in the production. Put your office or home address in it!
    cidr_blocks = ["0.0.0.0/0"]
  }

  //If you do not add this rule, you can not reach the NGIX
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nat-instance"
  }
}

resource "aws_security_group" "ALBSecurityGroup" {

  vpc_id = aws_vpc.prod-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "albsecuritygroup"
  }
}

resource "aws_security_group" "WebServersSecGroup" {

  vpc_id = aws_vpc.prod-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    // This means, all ip address are allowed to ssh !
    // Do not do it in the production. Put your office or home address in it!
    cidr_blocks = ["0.0.0.0/0"]
  }

  //If you do not add this rule, you can not reach the NGIX
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ALBSecurityGroup.id}"]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ALBSecurityGroup.id}"]
  }

  tags = {
    Name = "WebServersSecGroup"
  }
}