#------ dynamodb/outputs.tf ---

output "dynamodb_table_name" {
  value = aws_dynamodb_table.aws_capstone_dynamodb_table.id
}