variable "api-id"{}

variable "cert_arn" {}

variable "domain_name"{}

resource "aws_cloudfront_distribution" "resume_api_gateway_cf" {

  aliases = ["api.${var.domain_name}"]

  enabled = true
  is_ipv6_enabled = true
  comment             = "CloudFront distribution for the counter API - ${var.api-id}"
  default_root_object = ""

  origin {
    domain_name = "${var.api-id}.execute-api.eu-west-2.amazonaws.com"
    origin_id = "apigateway-${var.api-id}"

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
  }

  default_cache_behavior {
    target_origin_id = "apigateway-${var.api-id}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "PATCH", "POST", "DELETE"]
    cached_methods = ["GET", "HEAD"]

    cache_policy_id = aws_cloudfront_cache_policy.geo-cache-policy.id


    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  restrictions {
    geo_restriction {
    restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.cert_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
resource "aws_cloudfront_cache_policy" "geo-cache-policy" {
  name        = "geo-forwarding-policy"
  default_ttl = 50
  max_ttl     = 100
  min_ttl     = 1
  parameters_in_cache_key_and_forwarded_to_origin {
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["cloudfront-viewer-country"]
      }
    }
    cookies_config {
      cookie_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

# Output the CloudFront distribution domain name
output "cloudfront-api-domain-name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.resume_api_gateway_cf.domain_name
}

# Output the CloudFront distribution Z id
output "cloudfront-api-hz-id" {
  description = "The HZ ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.resume_api_gateway_cf.hosted_zone_id
}
