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

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.counter-lambda-invoke-arn

  passthrough_behavior = "WHEN_NO_TEMPLATES"

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

  passthrough_behavior = "WHEN_NO_TEMPLATES"
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
  passthrough_behavior = "WHEN_NO_TEMPLATES"

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

data "aws_caller_identity" "current" {}

resource "aws_api_gateway_deployment" "counter_api_deployment" {

  depends_on = [aws_api_gateway_rest_api.counter_api]
  rest_api_id = aws_api_gateway_rest_api.counter_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.counter_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 5. Stage "prod"
resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.counter_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.counter_api.id
  stage_name    = "prod"
}
