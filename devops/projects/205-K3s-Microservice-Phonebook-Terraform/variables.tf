variable "aws_region" {
  default = "us-east-1"
}

variable "access_ip" {}

#-------database variables

variable "dbname" {
  type = string
}
variable "dbuser" {
  type = string
}
variable "dbpassword" {
  type      = string
  sensitive = true
}
variable "zone_id" {
  type        = string
  default     = "Z07173933UX8PXKU4UCR5"
  description = "Route53 hosted zone ids"
}
variable "domain_name" {
  default = "mehmetafsar.com"
}
variable "cname" {
  default = "terraform"
}