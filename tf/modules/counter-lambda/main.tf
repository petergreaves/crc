terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "counter-table-name"{}
variable "filename"{
  type=string
  default="~/tmp/counter-lambda.zip"
}
data "aws_region" "current" {}


# the lambda 
resource "aws_lambda_function" "resume-counter-lambda" {
  function_name    = "resume-metrics-python-lambda-peter-greaves"
  description	   = "function that increments and returns the number of resume hits (from TF)"
  role             = aws_iam_role.counter-lambda-role.arn
  handler          = "counter_function.counter_handler"
  runtime          = "python3.10"
  filename         = var.filename

  source_code_hash    = "${filebase64(var.filename)}"
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
  value=aws_lambda_function.resume-counter-lambda.invoke_arn
}
output "function-name" {
  description="the function name of the hit counter lambda"
  value=aws_lambda_function.resume-counter-lambda.function_name
}
