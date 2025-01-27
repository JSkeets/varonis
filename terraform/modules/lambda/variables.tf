variable "service" {
  description = "Name of the service"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.service))
    error_message = "Service name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.function_name))
    error_message = "Function name must contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "ecr_repository_url" {
  description = "URL of the ECR repository"
  type        = string
}

variable "memory_size" {
  description = "Amount of memory in MB for the Lambda function"
  type        = number
  default     = 128

  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240
    error_message = "Memory size must be between 128 MB and 10240 MB."
  }
}

variable "timeout" {
  description = "Timeout in seconds for the Lambda function"
  type        = number
  default     = 3

  validation {
    condition     = var.timeout >= 1 && var.timeout <= 900
    error_message = "Timeout must be between 1 and 900 seconds."
  }
}

variable "vpc_id" {
  description = "VPC ID where the Lambda function will be deployed"
  type        = string

  validation {
    condition     = can(regex("^vpc-[a-z0-9]+$", var.vpc_id))
    error_message = "VPC ID must start with 'vpc-' followed by alphanumeric characters."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs where the Lambda function will be deployed"
  type        = list(string)

  validation {
    condition     = alltrue([for id in var.subnet_ids : can(regex("^subnet-[a-z0-9]+$", id))])
    error_message = "Subnet IDs must start with 'subnet-' followed by alphanumeric characters."
  }
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

variable "parameter_prefix" {
  description = "Prefix for SSM Parameter Store parameters"
  type        = string
}

variable "image_tag" {
  description = "The tag of the container image to deploy"
  type        = string
}

variable "audit_table_name" {
  description = "Name of the DynamoDB audit table"
  type        = string
}

variable "audit_table_arn" {
  description = "ARN of the DynamoDB audit table"
  type        = string
}