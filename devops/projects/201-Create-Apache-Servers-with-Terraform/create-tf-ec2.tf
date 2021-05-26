provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
#  if you used these credentials in your AWS CLI before,
#  you do not need to use these arguments.
}

data "aws_ami" "amazon-linux-2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "aws_iam_role" "tf-role" {
  name = "terraform-ec2"  #your role name if exist
}

resource "aws_instance" "terraform-ec2" {
  ami             = data.aws_ami.amazon-linux-2.id
  instance_type   = "t2.micro"
  key_name        = "northvirginia"  #your pem file name
  security_groups = ["terraform-sec-grp"]


  iam_instance_profile = data.aws_iam_role.tf-role.id

  tags = {
    Name = "terraform-oliver-new"
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo yum install -y yum-utils
                sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
                sudo yum -y install terraform
                EOF

}

resource "aws_security_group" "tf-sec-gr" {
  name = "terraform-sec-grp"

  tags = {
    Name = "tf-sec-grp"
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "ami-id" {
  value = data.aws_ami.amazon-linux-2.id
}
