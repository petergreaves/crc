# outputs.tf
output "dynamodb-table-name" {
  description = "Name of the DynamoDB table"
  value       = module.db.metrics-table-name
}

output "dynamodb-table-arn" {
  description = "ARN of the DynamoDB table"
  value       = module.db.metrics_table_arn
}

output "dynamodb-table-id" {
  description = "ID of the DynamoDB table"
  value       = module.db.metrics_table_id
}

output "api-gw-url"{
  description = "the URL of the api gateway for the counter function"
  value       = module.api-gw.api_gateway_url
}
output "counter-lambda-name"{
  description = "the name of the lambda function"
  value       = module.lambda.function_name
}
output "api-gw-arn" {
  description = "The  ARN of the API Gateway"
  value       = module.api-gw.api-gw-arn
}

output "api-gw-exec-arn" {

  description = "The exec ARN of the API Gateway"
  value       = module.api-gw.api-gw-exec-arn
}

# Output the CloudFront distribution domain name
output "cloudfront-api-domain-name" {
  description = "The domain name of the CloudFront distribution"
  value       = module.cloud-front-api.cloudfront-api-domain-name
}
