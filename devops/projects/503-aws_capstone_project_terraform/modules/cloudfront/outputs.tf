#------ cloudfront/outputs.tf ---

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.aws_capstone_distribution.domain_name
}

output "cloudfront_hosted_zone_id" {
  value = aws_cloudfront_distribution.aws_capstone_distribution.hosted_zone_id
}

output "cloudfront_dnsname" {
  value = join("", ["https://","${aws_cloudfront_distribution.aws_capstone_distribution.domain_name}"])
}