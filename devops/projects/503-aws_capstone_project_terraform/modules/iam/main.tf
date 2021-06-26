#------ iam/main.tf ---

resource "aws_iam_role" "ec2_s3_access_role" {
  name               = "aws-capstone-ec2-s3-full-access"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "s3_full_access" {
  name        = "aws-capstone-s3-full-access"
  description = "aws-capstone-s3-full-access"
  policy      = <<EOF
{
  "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_iam_policy_attachment" "policy_attach_to_role" {
  name       = "aws-capstone-attachment"
  roles      = [aws_iam_role.ec2_s3_access_role.name]
  policy_arn = aws_iam_policy.s3_full_access.arn
}

resource "aws_iam_instance_profile" "aws_capstone_instance_profile" {
  name = "aws_capstone_ec2_s3_full_access"
  role = aws_iam_role.ec2_s3_access_role.name
}

resource "aws_iam_role" "aws_capstone_lambda_role" {
  name               = "aws-capstone-lambda-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  managed_policy_arns = [ "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
                           "arn:aws:iam::aws:policy/AmazonS3FullAccess",
                           "arn:aws:iam::aws:policy/job-function/NetworkAdministrator" ]
}