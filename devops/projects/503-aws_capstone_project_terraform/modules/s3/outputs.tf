#------ s3/outputs.tf ---

output "blog_bucket_name" {
  value = aws_s3_bucket.aws_capstone_s3_blog.id
}

output "blog_bucket_arn" {
  value = aws_s3_bucket.aws_capstone_s3_blog.arn
}

output "s3_website_endpoint" {
  value = aws_s3_bucket.aws_capstone_s3_website.website_endpoint
}

output "s3_hosted_zone_id" {
  value = aws_s3_bucket.aws_capstone_s3_website.hosted_zone_id
}