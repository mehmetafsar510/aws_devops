# Please change the key_name and your config file 
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.37.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
}

variable "secgr-dynamic-ports" {
  default = [22,80,443]
}

variable "instance-type" {
  default = "t2.micro"
  sensitive = true
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  dynamic "ingress" {
    for_each = var.secgr-dynamic-ports
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

  # ingress {
  #   description = "SSH into VPC"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    description = "Outbound Allowed"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "tf-ec2" {
  ami           = "ami-0742b4e673072066f"
  instance_type = var.instance-type
  key_name = "mk"
  vpc_security_group_ids = [ aws_security_group.allow_ssh.id ]
  iam_instance_profile = "terraform"
      tags = {
      Name = "main-tf"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y yum-utils
              yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
              yum -y install terraform
              cd /home/ec2-user/ && mkdir terraform-aws && cd terraform-aws
              touch main.tf
	            EOF
  
#   provisioner "remote-exec" {
#      inline = [
#        "sudo yum update -y",
#        "sudo yum install -y yum-utils",
#        "sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo",
#        "sudo yum -y install terraform",
#        "mkdir terraform-aws && cd terraform-aws",
#        "touch main.tf",
#      ]
#    connection {
#      type = "ssh"
#      user = "ec2-user"
#      private_key = file("~/.ssh/mk.pem")
#      host = self.public_ip
#    }
# }
#   depends_on = [
#     aws_security_group.allow_ssh,
#   ]
# }

provisioner "local-exec" {
  command = "echo ${self.public_ip} >> C:/Users/Aktif/.ssh/config"
  }
}

output "myec2-public-ip" {
  value = aws_instance.tf-ec2.public_ip
  sensitive = true
}