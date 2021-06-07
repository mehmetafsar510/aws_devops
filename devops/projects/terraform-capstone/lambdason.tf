
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "S3Full" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.iam_for_lambda.name
}

resource "aws_iam_role_policy_attachment" "NetworkAdministrator" {
  policy_arn = "arn:aws:iam::aws:policy/job-function/NetworkAdministrator"
  role       = aws_iam_role.iam_for_lambda.name
}

resource "aws_iam_role_policy_attachment" "DynamoDB" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = aws_iam_role.iam_for_lambda.name
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}

data "archive_file" "lambda_zip_file_int" {
  type        = "zip"
  output_path = "./templates/lambda_function.zip"
  source {
    content  = templatefile("${path.module}/templates/lambda_function.py", { Dynamodb = "${aws_dynamodb_table.dynamodb-table.id}" })
    filename = "lambda_function.py"
  }
}
resource "aws_lambda_function" "func" {
  function_name    = "my-lambda1"
  description      = "My awesome lambda function"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  memory_size      = "128"
  role             = aws_iam_role.iam_for_lambda.arn
  filename         = data.archive_file.lambda_zip_file_int.output_path
  source_code_hash = data.archive_file.lambda_zip_file_int.output_base64sha256
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = "public-read"
  policy = templatefile("${path.module}/templates/s3-policy.json", { bucket = "${var.bucket_name}" })

  website {
    index_document = "index.html"
  }

  tags = var.common_tags
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${var.bucket_name}" #değiştir

  lambda_function {
    lambda_function_arn = aws_lambda_function.func.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}


resource "aws_dynamodb_table" "dynamodb-table" {
  name           = "my_table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
  tags = {
    Terraform   = "true"
    Environment = "staging"
  }
}