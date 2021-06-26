#------ dynamodb/main.tf ---

resource "aws_dynamodb_table" "aws_capstone_dynamodb_table" {
  name           = "awscapstoneDynamo"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

}