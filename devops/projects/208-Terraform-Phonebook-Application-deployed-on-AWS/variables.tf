variable "dbname" {
  type      = string
  sensitive = true
}

variable "dbuser" {
  type      = string
  sensitive = true
}

variable "dbpassword" {
  type = string
}

variable "PUBLIC_KEY_PATH" {
  default = "~/.ssh/id_rsa.pub"
}

variable "vpc_cidr" {
  type    = string
  default = "90.91.0.0/16"
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

