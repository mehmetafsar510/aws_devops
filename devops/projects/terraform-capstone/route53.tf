## Route 53 for domain
#resource "aws_route53_zone" "main" {
#  name = var.domain_name
#  tags = var.common_tags
#}

resource "aws_route53_health_check" "primary" {
  fqdn              = aws_cloudfront_distribution.www_elb_distribution.domain_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "5"
  request_interval  = "30"
  tags = {
    Name = "tf-test-health-check"
  }
}

resource "aws_route53_record" "web_domain" {
  zone_id         = var.zone_id
  name            = "terraform.${var.domain_name}"
  type            = "A"
  health_check_id = aws_route53_health_check.primary.id
  failover_routing_policy {
    type = "PRIMARY"
  }
  set_identifier = "${var.fqdn}-PRIMARY"

  alias {
    name                   = aws_cloudfront_distribution.www_elb_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.www_elb_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_s3_bucket" "this" {
  bucket = "terraform.${var.domain_name}"
  acl    = "public-read"

  tags = {
    Terraform = "true"
    Name      = "${var.env}-${var.name}"
  }

  website {
    index_document = "index.html"
  }
}



resource "aws_route53_record" "this" {
  zone_id = var.zone_id
  name    = "terraform.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_s3_bucket.this.website_domain
    zone_id                = aws_s3_bucket.this.hosted_zone_id
    evaluate_target_health = true
  }

  failover_routing_policy {
    type = "SECONDARY"
  }
  set_identifier = "${var.fqdn}-SECONDARY"
}

#Uncomment the below block if you are doing certificate validation using DNS instead of Email.
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.ssl_certificate.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = "${var.zone_id}"
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}
