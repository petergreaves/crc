variable "domain_name" { 
  description = "The external domain name for the api"
  type        = string
}

variable "hosted_zone_id" { 
  description = "The hosted_zone id"
  type        = string
}

variable "cf_api_domain_name" {
  description = "The Cloudfront domain name for the api"
  type        = string
}

variable "cf_api_hz_id" {
  description = "The Cloudfront HZ ID for the api"
  type        = string
}

variable "evaluate_target_health" {
  description = "Whether Route53 should evaluate target health"
  type        = bool
  default     = false
}

# Create the A record for api.peter-greaves.net pointing to CloudFront
resource "aws_route53_record" "api_subdomain" {

  zone_id = var.hosted_zone_id
  name    = "api.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.cf_api_domain_name
    zone_id                = var.cf_api_hz_id
    evaluate_target_health = false
  }
}

# Create the AAAA record for IPv6 support
resource "aws_route53_record" "api_subdomain_ipv6" {

  zone_id = var.hosted_zone_id
  name    = "api.${var.domain_name}"
  type    = "AAAA"

  alias {
    name                   = var.cf_api_domain_name
    zone_id                = var.cf_api_hz_id
    evaluate_target_health = false
  }
}

# Provider configuration
provider "aws" {
  region = "eu-west-2"
}

# Provider for ACM certificate (must be in us-east-1 for CloudFront)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}