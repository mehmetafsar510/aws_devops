output "lb_target_group_arn1" {
  value = aws_lb_target_group.mtc_tg_1.arn
}
output "lb_target_group_arn2" {
  value = aws_lb_target_group.mtc_tg_2.arn
}
output "lb_endpoint" {
  value = aws_lb.mtc_lb.dns_name
}