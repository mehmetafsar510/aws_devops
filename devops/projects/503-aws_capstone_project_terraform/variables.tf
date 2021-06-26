#------ root/variables.tf ---

variable "aws_region" {
  default = "us-east-1"
}

variable "access_ip" {
  type = string
}

variable "alb_security_group" {
  default = [80, 443]
}
variable "ec2_security_group" {
  default = [80, 443]
}
variable "rds_security_group" {
  default = [3306]
}
variable "natinstance_security_group" {
  default = [22, 80, 443]
}

#variable "service_type" {
#  description = "Available types of instance."
#  type        = list(string)
#  default     = [
#    "Gateway",
#    "Interface",
#  ]
#}
#
#variable "service_name" {
#  description = "Available types of instance."
#  type        = list(string)
#  default     = [
#    "com.amazonaws.us-east-1.s3",
#    "com.amazonaws.us-east-1.dynamodb",
#    "com.amazonaws.us-east-1.ec2",
#  ]
#}
variable "endpoint" {
  description = "Tags to set for all resources"
  type        = map(string)
  default = {
    s3                = "com.amazonaws.us-east-1.s3",
    dynamodb          = "com.amazonaws.us-east-1.dynamodb",
    ec2               = "com.amazonaws.us-east-1.ec2",
    service_gateway   = "Gateway",
    service_interface = "Interface",
  }
}

variable "instance_type" {
  description = "Available types of instance."
  type        = list(string)
  default = [
    "t2.micro",
    "t3a.medium",
    "t2.medium",
  ]
}
variable "db_engine_version" {
  description = "Available types of db engine version."
  type        = string
  default     = "8.0.20"
}
variable "db_instance_type" {
  description = "Available types of instance."
  type        = list(string)
  default = [
    "db.t2.micro",
    "db.t3a.medium",
    "db.t2.medium",
  ]
}
variable "key_name" {
  type    = string
  default = "the_doctor"
}

variable "zone_id" {
  type        = string
  default     = "Z07173933UX8PXKU4UCR5"
  description = "Route53 hosted zone ids"
}
variable "origin_id" {
  type        = string
  description = "The id of the origin"
  default     = "ALBOriginId"
}
variable "origin_http_port" {
  type        = number
  description = "The HTTP port the custom origin listens on"
  default     = 80
}

variable "origin_https_port" {
  type        = number
  description = "The HTTPS port the custom origin listens on"
  default     = 443
}

variable "origin_protocol_policy" {
  type        = string
  description = "The origin protocol policy to apply to your origin. One of http-only, https-only, or match-viewer"
  default     = "match-viewer"
}

variable "origin_ssl_protocols" {
  description = "The SSL/TLS protocols that you want CloudFront to use when communicating with your origin over HTTPS"
  type        = list(string)
  default     = ["TLSv1"]
}
variable "viewer_minimum_protocol_version" {
  type        = string
  description = "The minimum version of the SSL protocol that you want CloudFront to use for HTTPS connections."
  default     = "TLSv1"
}
variable "forward_cookies" {
  type        = string
  description = "Specifies whether you want CloudFront to forward cookies to the origin. Valid options are all, none or whitelist"
  default     = "all"
}
variable "viewer_protocol_policy" {
  type        = string
  description = "allow-all, redirect-to-https"
  default     = "redirect-to-https"
}
variable "allowed_methods" {
  type        = list(string)
  default     = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  description = "List of allowed methods (e.g. ` GET, PUT, POST, DELETE, HEAD`) for AWS CloudFront"
}

variable "cached_methods" {
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
  description = "List of cached methods (e.g. ` GET, PUT, POST, DELETE, HEAD`)"
}
variable "forward_headers" {
  description = "Specifies the Headers, if any, that you want CloudFront to vary upon for this cache behavior. Specify `*` to include all headers."
  type        = list(string)
  default     = ["Host", "Accept", "Accept-Charset", "Accept-Datetime", "Accept-Encoding", "Accept-Language", "Authorization", "Cloudfront-Forwarded-Proto", "Origin", "Referrer"]
}
variable "compress" {
  type        = bool
  description = "Whether you want CloudFront to automatically compress content for web requests that include Accept-Encoding: gzip in the request header (default: false)"
  default     = true
}
variable "forward_query_string" {
  type        = bool
  default     = true
  description = "Forward query strings to the origin that is associated with this cache behavior"
}
variable "geo_restriction_type" {
  # e.g. "whitelist"
  type        = string
  default     = "none"
  description = "Method that use to restrict distribution of your content by country: `none`, `whitelist`, or `blacklist`"
}

variable "distribution_enabled" {
  type        = bool
  default     = true
  description = "Set to `true` if you want CloudFront to begin processing requests as soon as the distribution is created, or to false if you do not want CloudFront to begin processing requests after the distribution is created."
}
variable "ssl_support_method" {
  type    = string
  default = "sni-only"
}
variable "domain_name" {
  default = "mehmetafsar.com"
}
variable "cname" {
  default = "capstone"
}
variable "skip_final_snapshot" {
  type    = bool
  default = true
}
variable "identifier" {
  type    = string
  default = "aws-capstone-rds"
}
variable "backup_window" {
  default = "22:00-03:00"
}
variable "maintenance_window" {
  default = "Sun:03:00-Sun:04:00"
}
variable "rds_engine_type" {
  default = "mysql"
}
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