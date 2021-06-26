#------ elb-asg/outputs.tf ---

output "lb_target_group_arn" {
  value = aws_lb_target_group.aws_capstone_tg.arn
}

output "lb_endpoint" {
  value = aws_lb.aws_capstone_alb.dns_name
}
output "elb_dnsname" {
  value = join("", ["https://","${aws_lb.aws_capstone_alb.dns_name}"])
  
}