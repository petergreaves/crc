resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/resume-metrics-python-lambda"
  retention_in_days = 14
}
