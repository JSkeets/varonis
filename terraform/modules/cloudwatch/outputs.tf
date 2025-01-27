output "api_gateway_log_group_arn" {
  description = "ARN of the API Gateway CloudWatch log group"
  value       = aws_cloudwatch_log_group.api_gateway.arn
}

output "dynamodb_log_group_arn" {
  description = "ARN of the DynamoDB CloudWatch log group"
  value       = aws_cloudwatch_log_group.dynamodb.arn
}

output "lambda_log_group_arn" {
  description = "ARN of the Lambda CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda.arn
}

output "vpc_flow_log_group_arn" {
  description = "ARN of the VPC Flow Logs CloudWatch log group"
  value       = aws_cloudwatch_log_group.vpc_flow_logs.arn
} 