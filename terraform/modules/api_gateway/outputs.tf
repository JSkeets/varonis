output "api_gateway_url" {
  value = aws_api_gateway_deployment.this.invoke_url
}

output "execution_arn" {
  value = aws_api_gateway_rest_api.this.execution_arn
}