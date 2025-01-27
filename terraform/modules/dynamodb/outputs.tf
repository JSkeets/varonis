output "table_id" {
  description = "DynamoDB table ID"
  value       = aws_dynamodb_table.this.id
}

output "table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.this.arn
}

output "table_stream_arn" {
  description = "DynamoDB table stream ARN"
  value       = aws_dynamodb_table.this.stream_arn
} 