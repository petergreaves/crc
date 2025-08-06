output "metrics_table_name" {
  value = "${aws_dynamodb_table.metrics.name}"
}
output "metrics_table_arn" {
  value = "${aws_dynamodb_table.metrics.arn}"
}
output "metrics_table_id" {
  value = "${aws_dynamodb_table.metrics.id}"
}
