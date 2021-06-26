#------ vpc/variables.tf ---

variable "vpc_cidr" {
  type = string
}

variable "public_cidrs" {
  type = list(any)
}

variable "private_cidrs" {
  type = list(any)
}

variable "public_sn_count" {
  type = number
}

variable "private_sn_count" {
  type = number
}

variable "max_subnets" {
  type = number
}

variable "access_ip" {
  type = string
}

variable "alb_security_group" {}

variable "ec2_security_group" {}

variable "rds_security_group" {}

variable "natinstance_security_group" {}

variable "db_subnet_group" {
  type = bool
}

variable "service_name" {}

variable "service_type" {}

variable "network_interface_id" {}