#------ s3/main.tf ---

resource "random_integer" "random" {
  min = 100
  max = 1000
}

resource "aws_s3_bucket" "aws_capstone_s3_blog" {
  bucket = "aws-capstone-s3-blog-${random_integer.random.id}"
  force_destroy = true
  acl    = "public-read"
}

resource "aws_s3_bucket" "aws_capstone_s3_website" {
  bucket = join("", ["${var.cname}.", "${var.domain_name}"])
  acl    = "public-read"
  force_destroy = true
  #policy = file("policy.json")

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_object" "aws_capstone_object" {
  for_each = fileset("${var.static_website_files}/", "*")
  key      = each.value
  bucket   = aws_s3_bucket.aws_capstone_s3_website.id
  source   = "${var.static_website_files}/${each.value}"

}

resource "aws_s3_bucket_policy" "aws_capstone_website_policy" {
  bucket = aws_s3_bucket.aws_capstone_s3_website.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          "${aws_s3_bucket.aws_capstone_s3_website.arn}/*"
        ]
      }
    ]
  })
}