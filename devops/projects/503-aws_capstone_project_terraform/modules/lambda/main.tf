#------ lambda/main.tf ---

data "archive_file" "lambda_zip_file_int" {
  type        = "zip"
  output_path = var.output_path
  source {
    content  = templatefile("${path.root}/modules/files/lambda_function.py", { dynamodb = "${var.dynamodb_table_name}" })
    filename = "lambda_function.py"
  }
}

resource "aws_lambda_function" "aws_capstone_lambda" {
  filename      = var.output_path
  function_name = "awscapstonelambdafunction"
  role          = var.iam_role_for_lambda
  handler       = "lambda_function.lambda_handler"

  source_code_hash = filebase64sha256("${var.output_path}")

  runtime = "python3.8"

}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.aws_capstone_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.source_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.bucket_name 

  lambda_function {
    lambda_function_arn = aws_lambda_function.aws_capstone_lambda.arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_prefix = "media/"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}