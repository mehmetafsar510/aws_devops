#------ route53/main.tf ---

resource "aws_route53_health_check" "aws_capstone_health_check" {
  fqdn              = var.fqdn
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "5"
  request_interval  = "30"

  tags = {
    Name = "aws-capstone-health-check"
  }
}

data "aws_route53_zone" "aws_capstone_zone" {
  name = var.domain_name
}

resource "aws_route53_record" "aws_capstone_record1" {
  zone_id = data.aws_route53_zone.aws_capstone_zone.zone_id
  name    = join("", ["${var.cname}.","${data.aws_route53_zone.aws_capstone_zone.name}"])
  type    = "A"
  #ttl     = "300"

  failover_routing_policy {
    type = "PRIMARY"
  }

  alias {
    name                   = var.fqdn
    zone_id                = var.zone_id
    evaluate_target_health = true
  }

  set_identifier  = "Primary"
  health_check_id = aws_route53_health_check.aws_capstone_health_check.id
}

resource "aws_route53_record" "aws_capstone_record2" {
  zone_id = data.aws_route53_zone.aws_capstone_zone.zone_id
  name    = join("", ["${var.cname}.","${data.aws_route53_zone.aws_capstone_zone.name}"])
  type    = "A"
  #ttl     = "300"

  failover_routing_policy {
    type = "SECONDARY"
  }

  alias {
    name                   = var.alias_s3
    zone_id                = var.zone_id_s3
    evaluate_target_health = true
  }

  set_identifier  = "Secondary"
  health_check_id = aws_route53_health_check.aws_capstone_health_check.id
}
