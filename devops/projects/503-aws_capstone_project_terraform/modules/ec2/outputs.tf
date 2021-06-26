#------ ec2/outputs.tf ---

output "network_interface_id" {
  value = aws_instance.aws_capstone_natinstance.primary_network_interface_id
}