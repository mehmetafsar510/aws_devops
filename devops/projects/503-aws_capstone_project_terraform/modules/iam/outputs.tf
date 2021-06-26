#------ iam/outputs.tf ---

output "aws_capstone_ec2_s3_full_access" {
  value = aws_iam_instance_profile.aws_capstone_instance_profile.arn
}

output "iam_role_for_lambda" {
  value = aws_iam_role.aws_capstone_lambda_role.arn
}