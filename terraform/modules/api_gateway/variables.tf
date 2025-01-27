variable "service" {
  type        = string
  description = "Name of the service"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.service))
    error_message = "Service name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "openapi_spec_path" {
  type        = string
  description = "Path to the OpenAPI specification template"

  validation {
    condition     = can(regex(".*\\.ya?ml$", var.openapi_spec_path))
    error_message = "OpenAPI spec path must end with .yml or .yaml"
  }
}

variable "region" {
  type        = string
  description = "The AWS region"
}

variable "integrations" {
  type = map(object({
    uri         = string
    type        = string
    http_method = string
    timeout_ms  = number
  }))
  description = "Map of API Gateway integrations"

  validation {
    condition     = alltrue([for i in var.integrations : i.timeout_ms >= 1000 && i.timeout_ms <= 29000])
    error_message = "Timeout must be between 1000 and 29000 milliseconds."
  }
}

variable "description" {
  type        = string
  description = "The description of the API"
}

variable "allowed_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks allowed to access the API"

  validation {
    condition     = alltrue([for cidr in var.allowed_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All elements must be valid CIDR blocks."
  }
}

variable "api_name" {
  type        = string
  description = "The name of the API"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the API Gateway VPC endpoint"
  type        = list(string)
}
