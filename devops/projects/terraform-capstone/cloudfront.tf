# Cloudfront distribution for main s3 site.
resource "aws_cloudfront_distribution" "www_elb_distribution" {
  origin {
    domain_name = aws_lb.front_end.dns_name
    origin_id   = "ELB-${aws_lb.front_end.name}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1"]
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = ["terraform.${var.domain_name}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "ELB-${aws_lb.front_end.name}"

    forwarded_values {
      query_string = true
      headers      = ["Host", "Accept", "Accept-Charset", "Accept-Datetime", "Accept-Encoding", "Accept-Language", "Authorization", "Cloudfront-Forwarded-Proto", "Origin", "Referrer"]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 31536000
    default_ttl            = 31536000
    max_ttl                = 31536000
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  tags = var.common_tags
}

output "cloudfront_dnsname" {
  value = join("", ["https://", "${aws_cloudfront_distribution.www_elb_distribution.domain_name}"])
}

