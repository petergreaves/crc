# Configure website content bucket versioning
resource "aws_s3_bucket_versioning" "website_bucket_versioning" {
  bucket = aws_s3_bucket.website-bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}
