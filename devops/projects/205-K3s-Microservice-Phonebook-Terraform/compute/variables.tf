# --- compute/variables.tf ---

variable "instance_count" {}
variable "instance_type" {}
variable "public_sg" {}
variable "public_subnets" {}
variable "vol_size" {}
variable "public_key_path" {}
variable "key_name" {}
variable "dbuser" {}
variable "dbname" {}
variable "dbpassword" {}
variable "db_endpoint" {}
variable "user_data_path" {}
variable "lb_target_group_arn1" {}
variable "lb_target_group_arn2" {}
variable "private_key_path" {}
variable "tg_port1" {}
variable "tg_port2" {}
