output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "invoke_arn" {
  description = "Invoke ARN of the Lambda function - this is the ARN to use for API Gateway integration"
  value       = aws_lambda_function.this.invoke_arn
}

output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "qualified_arn" {
  description = "ARN identifying your Lambda function version"
  value       = aws_lambda_function.this.qualified_arn
}