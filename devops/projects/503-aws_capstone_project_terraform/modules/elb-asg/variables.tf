#------ elb-asg/variables.tf ---

variable "alb_sg" {}
variable "public_subnets" {}
variable "tg_port" {}
variable "tg_protocol" {}
variable "vpc_id" {}
variable "lb_healthy_threshold" {}
variable "lb_unhealthy_threshold" {}
variable "lb_timeout" {}
variable "lb_interval" {}
variable "private_subnets" {}
variable "launch_template_id" {}
variable "launch_template_latest_version" {}
variable "certificate_arn_elb" {}
#variable "listener_port" {}
#variable "listener_protocol" {}

