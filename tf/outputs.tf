# outputs.tf
output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = module.db.metrics_table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = module.db.metrics_table_arn
}

output "dynamodb_table_id" {
  description = "ID of the DynamoDB table"
  value       = module.db.metrics_table_id
}

output "api-gw-url"{
  description = "the URL of the api gateway for the counter function"
  value       = module.api-gw.api_gateway_url
}
