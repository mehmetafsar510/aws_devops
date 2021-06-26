#------ vpc/outputs.tf ---

output "vpc_id" {
  value = aws_vpc.aws_capstone_vpc.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.aws_capstone_rds_subnetgroup.*.name
}

output "db_security_group" {
  value = [aws_security_group.aws_capstone_rds_sg.id]
}

output "natinstance_sg" {
  value = aws_security_group.aws_capstone_natinstance_sg.id
}

output "alb_sg" {
  value = aws_security_group.aws_capstone_alb_sg.id
}

output "launch_template_sg" {
  value = aws_security_group.aws_capstone_ec2_sg.id
}

output "public_subnets" {
  value = aws_subnet.aws_capstone_public_subnet.*.id
}

output "private_subnets" {
  value = aws_subnet.aws_capstone_private_subnet.*.id
}