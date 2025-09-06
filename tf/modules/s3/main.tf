terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# the s3 bucket for the static content
resource "aws_s3_bucket" "website-bucket"{
  
  bucket=var.bucket_name

  lifecycle {
    ignore_changes = [
      website
    ]
  }
}


output "bucket-reg-domain-name" {
  value = aws_s3_bucket.website-bucket.bucket_regional_domain_name
}

output "bucket-arn" {
  value = "${aws_s3_bucket.website-bucket.arn}"
}


# s3 as website bucket config
resource "aws_s3_bucket_website_configuration" "website-bucket-conf" {
  bucket = aws_s3_bucket.website-bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Allow public access for website hosting
resource "aws_s3_bucket_public_access_block" "website-bucket-pab" {
  bucket = aws_s3_bucket.website-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket policy to allow public read access
resource "aws_s3_bucket_policy" "website-bucket-policy" {
  bucket = aws_s3_bucket.website-bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website-bucket.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.website-bucket-pab]
}
