#------ ec2/main.tf ---

data "aws_ami" "natinstance_ami" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat-hvm-*"]
  }
}

resource "aws_instance" "aws_capstone_natinstance" {
  instance_type          = var.instance_type # t2.micro
  ami                    = data.aws_ami.natinstance_ami.id
  key_name               = var.key_name
  vpc_security_group_ids = [var.natinstance_sg]
  subnet_id              = var.public_subnets
  source_dest_check      = false
  tags = {
    "Name" = "aws_capstone_natinstance"
  }

}