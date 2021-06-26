#------ database/variables.tf ---

variable "db_storage" {}
variable "engine" {}
variable "db_instance_class" {}
variable "dbname" {}
variable "dbuser" {}
variable "dbpassword" {}
variable "vpc_security_group_ids" {}
variable "db_subnet_group_name" {}
variable "db_engine_version" {}
variable "db_identifier" {}
variable "skip_db_snapshot" {}
variable "backup_retention_period" {}
variable "backup_window" {}
variable "maintenance_window" {}
variable "deletion_protection" {}
