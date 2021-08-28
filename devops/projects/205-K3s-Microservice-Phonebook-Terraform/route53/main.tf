data "aws_route53_zone" "aws_capstone_zone" {
  name = var.domain_name
}
data "aws_elb_hosted_zone_id" "main" {}

resource "aws_route53_record" "web_domain" {
  zone_id         = var.zone_id
  name            = join("", ["${var.cname}.","${data.aws_route53_zone.aws_capstone_zone.name}"])
  type            = "A"
  alias {
    name                   = var.dns_name
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = false
  }
}

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

# SSL Certificate
resource "aws_acm_certificate" "ssl_certificate" {
  #provider                  = aws.acm_provider
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  #validation_method         = "EMAIL"
  validation_method = "DNS"
  tags = {
    Name = "mehmetafsar.com"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Uncomment the validation_record_fqdns line if you do DNS validation instead of Email.
resource "aws_acm_certificate_validation" "cert_validation" {
  #provider                = aws.acm_provider
  certificate_arn         = aws_acm_certificate.ssl_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}