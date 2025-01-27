variable "service" {
  description = "Service name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "ecr_repository_url" {
  description = "URL of the ECR repository"
  type        = string
}

variable "image_tag" {
  description = "Tag of the container image"
  type        = string
  default     = "latest"
}

variable "memory_size" {
  description = "Amount of memory in MB for the Lambda function"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Timeout in seconds for the Lambda function"
  type        = number
  default     = 30
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Lambda function"
  type        = list(string)
}

variable "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  type        = string
}

variable "enable_dynamodb_access" {
  description = "Enable DynamoDB access for the Lambda function"
  type        = bool
  default     = false
}

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  type        = string
  default     = null
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = null
}

variable "dynamodb_stream_arn" {
  description = "ARN of the DynamoDB stream"
  type        = string
  default     = null
}