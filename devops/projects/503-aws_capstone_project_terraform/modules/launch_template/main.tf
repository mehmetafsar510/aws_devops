#------ launh_template/main.tf ---

data "aws_ami" "aws_capstone_ubuntu_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

# data "template_file" "init" {
#   template = "${file("${var.user_data_path}")}"
#   vars = {
#     db_address  = var.db_address
#     dbuser      = var.dbuser
#     dbpassword  = var.dbpassword
#     dbname      = var.dbname
#     bucket_name = var.bucket_name
#   }
# }

data "template_cloudinit_config" "config" {
  #gzip          = false
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    #filename     = "init.cfg"
    content_type = "text/x-shellscript"
    #content = "${data.template_file.init.rendered}"
    content = templatefile(var.user_data_path,
      {
        db_address  = var.db_address
        dbuser      = var.dbuser
        dbpassword  = var.dbpassword
        dbname      = var.dbname
        bucket_name = var.bucket_name
      }
    )
  }
}

resource "aws_launch_template" "aws_capstone_launch_template" {
  name                   = "aws_capstone_launch_template"
  image_id               = data.aws_ami.aws_capstone_ubuntu_ami.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.launch_template_sg]
  #subnet_id              = var.private_subnets
  iam_instance_profile {
    arn = var.iam_instance_profile
  }
  user_data = data.template_cloudinit_config.config.rendered
  tag_specifications {
    resource_type = "instance"
    tags = {
      "Name" = "Web Server of AWS Capstone Project"
    }
  }
}