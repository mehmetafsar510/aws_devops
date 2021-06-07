
variable "AWS_REGION" {
  default = "us-east-1"
}

variable "fqdn" {
  description = "The FQDN of the endpoint to be monitored"
}

variable "env" {}

variable "domain" {}

variable "domain_config" {
  type = map(string)
  default = {
    domain         = "mehmetafsar.com"
    elb_sub_domain = "elb"
  }
}

variable "name" {
  description = "The name of the monitoring and name of the subscription service endpoint"
}

variable "EC2_USER" {
  default = "ubuntu"
}
variable "AMI" {
  type = map(string)

  default = {
    eu-west-2 = "ami-03dea29b0216a1e03"
    us-east-1 = "ami-013f17f36f8b1fefb"
  }
}
variable "domain_name" {
  type        = string
  description = "The domain name for the website."
}

variable "bucket_name" {
  type        = string
  description = "The name of the bucket without the www. prefix. Normally domain_name."
}

variable "common_tags" {
  description = "Common tags you want applied to all components."
}
variable "database_name" {
  type        = string
  default     = "clarusway"
  description = "The name of the database to create when the DB instance is created"
}

variable "database_user" {
  type        = string
  default     = "clarusway"
  description = "(Required unless a `snapshot_identifier` or `replicate_source_db` is provided) Username for the master DB user"
}

variable "database_password" {
  type        = string
  default     = "Pp12345678"
  description = "(Required unless a snapshot_identifier or replicate_source_db is provided) Password for the master DB user"
}
variable "zone_id" {
  type        = string
  default     = "Z07173933UX8PXKU4UCR5"
  description = "Route53 hosted zone ids"
}
variable "database_port" {
  type        = number
  default     = "3306"
  description = "Database port (_e.g._ `3306` for `MySQL`). Used in the DB Security Group to allow access to the DB instance from the provided `security_group_ids`"
}

