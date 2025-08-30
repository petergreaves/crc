terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}



# create dynamo db table for metrics
# DynamoDB table for metrics
resource "aws_dynamodb_table" "metrics" {
  name           = "metrics"
  billing_mode   = "PROVISIONED"  # Use provisioned capacity for free tier
  hash_key       = "hits"


  attribute {
    name = "hits"
    type = "S"
  }
  
  # Free tier includes 25 RCUs and 25 WCUs
  read_capacity  = 5   # Well within free tier limit
  write_capacity = 5   # Well within free tier limit

  # Enable point-in-time recovery
  point_in_time_recovery {
    enabled = true
  }

  # Server-side encryption
  server_side_encryption {
    enabled = true
  }

  # TTL configuration (optional)
  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = {
    Name        = "metrics-table"
  }
}
