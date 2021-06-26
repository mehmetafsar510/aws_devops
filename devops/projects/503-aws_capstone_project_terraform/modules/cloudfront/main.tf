#------ cloudfront/main.tf ---

resource "aws_cloudfront_distribution" "aws_capstone_distribution" {
  origin {
    domain_name = var.domain_name
    origin_id   = var.origin_id

    custom_origin_config {
      origin_protocol_policy   = var.origin_protocol_policy
      http_port                = var.http_port
      https_port               = var.https_port
      origin_keepalive_timeout = var.origin_keepalive_timeout
      origin_ssl_protocols     = var.origin_ssl_protocols
    }
  }

  enabled = var.enabled
  #is_ipv6_enabled     = true
  comment = "Cloudfront Distribution pointing to ALBDNS"
  #default_root_object = "index.html"

  aliases = var.aliases

  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.cached_methods
    target_origin_id = var.origin_id

    forwarded_values {
      query_string = var.query_string
      cookies {
        forward = var.cookies_forward
      }
      headers = var.headers
    }
    compress               = var.compress
    viewer_protocol_policy = var.viewer_protocol_policy
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method  = var.ssl_support_method
    minimum_protocol_version = var.minimum_protocol_version
  }


  restrictions {
    geo_restriction {
      restriction_type = var.restriction_type
      #locations        = ["US", "CA", "GB", "DE"]
    }
  }
}  