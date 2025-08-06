# Variables
variable "counter-lambda-invoke-arn" {
  description = "The invoke ARN of the counter Lambda function"
  type        = string
}

variable "counter-lambda-function-name" {
  description = "The name of the Lambda function"
  type        = string
}


# Data source to get current AWS region
data "aws_region" "current" {}


# API Gateway REST API
resource "aws_api_gateway_rest_api" "counter_api" {
  name        = "counter-api"
  description = "API Gateway for counter application"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# API Gateway Resource for /api
resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = aws_api_gateway_rest_api.counter_api.id
  parent_id   = aws_api_gateway_rest_api.counter_api.root_resource_id
  path_part   = "api"
}

# API Gateway Resource for /api/counter
resource "aws_api_gateway_resource" "counter_resource" {
  rest_api_id = aws_api_gateway_rest_api.counter_api.id
  parent_id   = aws_api_gateway_resource.api_resource.id
  path_part   = "counter"
}

# OPTIONS Method (for CORS preflight)
resource "aws_api_gateway_method" "counter_options" {
  rest_api_id   = aws_api_gateway_rest_api.counter_api.id
  resource_id   = aws_api_gateway_resource.counter_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS Method Integration
resource "aws_api_gateway_integration" "counter_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.counter_api.id
  resource_id = aws_api_gateway_resource.counter_resource.id
  http_method = aws_api_gateway_method.counter_options.http_method
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# OPTIONS Method Response
resource "aws_api_gateway_method_response" "counter_options_response" {
  rest_api_id = aws_api_gateway_rest_api.counter_api.id
  resource_id = aws_api_gateway_resource.counter_resource.id
  http_method = aws_api_gateway_method.counter_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# OPTIONS Integration Response
resource "aws_api_gateway_integration_response" "counter_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.counter_api.id
  resource_id = aws_api_gateway_resource.counter_resource.id
  http_method = aws_api_gateway_method.counter_options.http_method
  status_code = aws_api_gateway_method_response.counter_options_response.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*.peter-greaves.net'"
  }
}

# GET Method
resource "aws_api_gateway_method" "counter_get" {
  rest_api_id   = aws_api_gateway_rest_api.counter_api.id
  resource_id   = aws_api_gateway_resource.counter_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# GET Method Integration with Lambda
resource "aws_api_gateway_integration" "counter_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.counter_api.id
  resource_id             = aws_api_gateway_resource.counter_resource.id
  http_method             = aws_api_gateway_method.counter_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.counter-lambda-invoke-arn
}

# GET Method Response
resource "aws_api_gateway_method_response" "counter_get_response" {
  rest_api_id = aws_api_gateway_rest_api.counter_api.id
  resource_id = aws_api_gateway_resource.counter_resource.id
  http_method = aws_api_gateway_method.counter_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# PUT Method
resource "aws_api_gateway_method" "counter_put" {
  rest_api_id   = aws_api_gateway_rest_api.counter_api.id
  resource_id   = aws_api_gateway_resource.counter_resource.id
  http_method   = "PUT"
  authorization = "NONE"
}

# PUT Method Integration with Lambda
resource "aws_api_gateway_integration" "counter_put_integration" {
  rest_api_id             = aws_api_gateway_rest_api.counter_api.id
  resource_id             = aws_api_gateway_resource.counter_resource.id
  http_method             = aws_api_gateway_method.counter_put.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.counter-lambda-invoke-arn
}

# PUT Method Response
resource "aws_api_gateway_method_response" "counter_put_response" {
  rest_api_id = aws_api_gateway_rest_api.counter_api.id
  resource_id = aws_api_gateway_resource.counter_resource.id
  http_method = aws_api_gateway_method.counter_put.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.counter-lambda-function-name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.counter_api.execution_arn}/*/*"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "counter_api_deployment" {
  depends_on = [
    aws_api_gateway_method.counter_get,
    aws_api_gateway_method.counter_put,
    aws_api_gateway_method.counter_options,
    aws_api_gateway_integration.counter_get_integration,
    aws_api_gateway_integration.counter_put_integration,
    aws_api_gateway_integration.counter_options_integration,
  ]
  
  rest_api_id = aws_api_gateway_rest_api.counter_api.id
  
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_api_gateway_stage" "counter-api-stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.counter_api.id
  deployment_id = aws_api_gateway_deployment.counter_api_deployment.id
}

# Outputs
output "api_gateway_url" {
  description = "The URL of the API Gateway"
  value       = "https://${aws_api_gateway_rest_api.counter_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.counter-api-stage.stage_name}/api/counter"
}

output "api_gateway_id" {
  description = "The ID of the API Gateway"
  value       = aws_api_gateway_rest_api.counter_api.id
}

output "api_gateway_execution_arn" {
  description = "The execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.counter_api.execution_arn
}

