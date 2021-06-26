#------ launch_template/variables.tf ---

variable "instance_type" {}
variable "key_name" {}
variable "launch_template_sg" {}
variable "iam_instance_profile" {}
# variable "private_subnets" {}
variable "user_data_path" {}
variable "dbuser" {}
variable "dbname" {}
variable "dbpassword" {}
variable "db_address" {}
variable "bucket_name" {}
# variable "depends_on" {}