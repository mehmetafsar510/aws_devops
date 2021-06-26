#------ launch_template/outputs.tf ---

output "launch_template_id" {
  value = aws_launch_template.aws_capstone_launch_template.id
}

output "launch_template_latest_version" {
  value = aws_launch_template.aws_capstone_launch_template.latest_version
}