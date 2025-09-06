variable content-bucket-name{
  type = string
}
variable hz-name{
  type = string
}
variable hosted-zone-id {
  type=string
}

variable rec-prefix{
  type=string
}
variable bucket-reg-domain-name{
  type=string
}

variable bucket-arn{
  type=string
}

variable cert-arn{
  type=string
}

resource "aws_route53_record" "www-A" {
  zone_id = var.hosted-zone-id
  name    = "${var.rec-prefix}.${var.hz-name}."
  type    = "A"
 
alias {
  name                   = aws_cloudfront_distribution.resume_distribution.domain_name
  zone_id                = aws_cloudfront_distribution.resume_distribution.hosted_zone_id
  evaluate_target_health = false
  }
}


resource "aws_route53_record" "www-AAAA" {
  zone_id = var.hosted-zone-id
  name    = "${var.rec-prefix}.${var.hz-name}."
  type    = "AAAA"
 
alias {
  name                   = aws_cloudfront_distribution.resume_distribution.domain_name
  zone_id                = aws_cloudfront_distribution.resume_distribution.hosted_zone_id
  evaluate_target_health = false
  }
}

# Provider alias for us-east-1 (required for CloudFront certificates)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# Origin Access Control for S3 bucket access
resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "resume-bucket-oac"
  description                       = "Origin Access Control for resume bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# the CloudFront Distribution
resource "aws_cloudfront_distribution" "resume_distribution" {

  origin {
    domain_name              = var.bucket-reg-domain-name
    origin_id                = "S3-resume-bucket"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id

  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for resume bucket"
  default_root_object = "index.html"

  # Configure alternate domain names if needed
  aliases = ["about.peter-greaves.net"]  # Adjust as needed

  default_cache_behavior {
    allowed_methods        = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-resume-bucket"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
       cookies {
        forward = "none"
      }

    }

  }

  # Price class - adjust based on your needs
  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

 # Custom error pages configuration
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 300
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 300
  }


  # SSL Certificate configuration
  viewer_certificate {
    acm_certificate_arn      = var.cert-arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name        = "Resume Distribution"
    Environment = "production"
  }
}

# S3 bucket policy to allow CloudFront access
resource "aws_s3_bucket_policy" "resume-bucket-policy" {
  bucket = var.content-bucket-name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${var.bucket-arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.resume_distribution.arn
          }
        }
      }
    ]
  })
}

# Output the CloudFront distribution domain name
output "cloudfront-domain-name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.resume_distribution.domain_name
}

# Output the distribution ID
output "distribution-id" {
  description = "The CloudFront distribution ID"
  value       = aws_cloudfront_distribution.resume_distribution.id
}
