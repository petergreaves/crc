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


# Sample data items
resource "aws_dynamodb_table_item" "metrics_item_1" {
  table_name = aws_dynamodb_table.metrics.name
  hash_key   = aws_dynamodb_table.metrics.hash_key

  item = jsonencode({
    hits = {
      S = "hit_001"
    }
    hit_geo = {
      S = "US-NY-New York"
    }
    hit_dt = {
      S = "2024-08-20T10:30:00Z"
    }
  })
}

resource "aws_dynamodb_table_item" "metrics_item_2" {
  table_name = aws_dynamodb_table.metrics.name
  hash_key   = aws_dynamodb_table.metrics.hash_key

  item = jsonencode({
    hits = {
      S = "hit_002"
    }
    hit_geo = {
      S = "GB-ENG-London"
    }
    hit_dt = {
      S = "2024-08-20T14:45:30Z"
    }
  })
}

resource "aws_dynamodb_table_item" "metrics_item_3" {
  table_name = aws_dynamodb_table.metrics.name
  hash_key   = aws_dynamodb_table.metrics.hash_key

  item = jsonencode({
    hits = {
      S = "hit_003"
    }
    hit_geo = {
      S = "CA-ON-Toronto"
    }
    hit_dt = {
      S = "2024-08-20T08:15:45Z"
    }
  })
}

resource "aws_dynamodb_table_item" "metrics_item_4" {
  table_name = aws_dynamodb_table.metrics.name
  hash_key   = aws_dynamodb_table.metrics.hash_key

  item = jsonencode({
    hits = {
      S = "hit_004"
    }
    hit_geo = {
      S = "AU-NSW-Sydney"
    }
    hit_dt = {
      S = "2024-08-20T22:20:15Z"
    }
  })
}

resource "aws_dynamodb_table_item" "metrics_item_5" {
  table_name = aws_dynamodb_table.metrics.name
  hash_key   = aws_dynamodb_table.metrics.hash_key

  item = jsonencode({
    hits = {
      S = "hit_005"
    }
    hit_geo = {
      S = "DE-BE-Berlin"
    }
    hit_dt = {
      S = "2024-08-20T16:55:20Z"
    }
  })
}



