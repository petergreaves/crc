terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "random_string" "random" {
  length           = 12
  special          = false
  override_special = "/@£$"
  lower  = false
}


variable "counter-table-name" {}

variable "api_gateway_execution_arn" {
  description = "Base execution ARN from API Gateway (without path pattern)"
  type        = string
  default     = null
}

variable "api_gateway_source_arn_pattern" {
  description = "Path pattern for API Gateway source ARN"
  type        = string
  default     = "/*/*"  # Allow all stages and methods by default
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file  = "${path.module}/../../../src/counter_function.py"
  output_path = "${path.module}/../tmp/counter-lambda.zip"
}

data "aws_region" "current" {}
# the lambda 
resource "aws_lambda_function" "counter-lambda" {
  filename         = "${path.module}/../tmp/counter-lambda.zip"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  function_name    = "${random_string.random.result}-resume-metrics-lambda"
  description	   = "function that increments and returns the number of resume hits (from TF)"
  role             = aws_iam_role.counter-lambda-role.arn
  handler          = "counter_function.counter_handler"
  runtime          = "python3.10"
}

resource "aws_iam_role" "counter-lambda-role" {
  name = "counter_lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.counter-lambda.function_name
  principal     = "apigateway.amazonaws.com"
  
  source_arn = "${var.api_gateway_execution_arn}${var.api_gateway_source_arn_pattern}"
}

resource "aws_iam_policy" "counter-db-policy" {
  name        = "counter-lambda-dynamodb-policy"
  description = "Policy for Lambda to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = [
          "arn:aws:dynamodb:${data.aws_region.current.name}:*:table/${var.counter-table-name}",
          "arn:aws:dynamodb:${data.aws_region.current.name}:*:table/${var.counter-table-name}/index/*"
        ]
      }
    ]
  })
}

# Attach DynamoDB Policy to Lambda Role
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy" {
  role       = aws_iam_role.counter-lambda-role.name
  policy_arn = aws_iam_policy.counter-db-policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.counter-lambda-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

output "invoke-arn" {
  description="the arn of the hit counter lambda"
  value=aws_lambda_function.counter-lambda.invoke_arn
}
output "function-name" {
  description="the function name of the hit counter lambda"
  value=aws_lambda_function.counter-lambda.function_name
}
