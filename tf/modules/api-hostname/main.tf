# Variables
variable "api_domain_name" {
  description = "The custom domain name for the API"
  type        = string
}
variable "hosted_zone_id" {
  description = "Route53 hosted zone ID for peter-greaves.net"
  type        = string
}

variable "cf_domain_name" {
  description = "The CF domain name"
  type        = string
}

variable "cf_zone_id" {
  description = "The CF zone id"
  type        = string
}

variable "evaluate_target_health" {
  description = "Whether Route53 should evaluate target health"
  type        = bool
  default     = false
}

# Data source to get the existing hosted zone
data "aws_route53_zone" "main" {
  zone_id = var.hosted_zone_id
}

# ACM Certificate for the custom domain
resource "aws_acm_certificate" "api_cert" {
  domain_name       = var.api_domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "API Gateway Certificate"
  }
}

resource "aws_route53_record" "api_domain_record" {

  name    = var.api_domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.main.zone_id

  alias {
    evaluate_target_health = var.evaluate_target_health
    name    = var.cf_domain_name
    zone_id = var.cf_zone_id
  }
}

# DNS validation records for ACM certificate
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.api_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}

# ACM certificate validation
resource "aws_acm_certificate_validation" "api_cert_validation" {
  certificate_arn         = aws_acm_certificate.api_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}


output "api_certificate_arn" {
  description = "The ARN of the API ACM certificate"
  value       = aws_acm_certificate.api_cert.arn
}