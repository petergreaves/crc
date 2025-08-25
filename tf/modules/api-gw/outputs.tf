# Outputs
output "api_gateway_url" {
  description = "The URL of the API Gateway"
  value       = "https://${aws_api_gateway_rest_api.counter_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}/api/counter"
}

output "api_gateway_id" {
  description = "The ID of the API Gateway"
  value       = aws_api_gateway_rest_api.counter_api.id
}

output "api-gw-arn" {
  description = "The  ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.counter_api.arn
}

output "api-gw-exec-arn" {
  description = "The  exec ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.counter_api.execution_arn
}