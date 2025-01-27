variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name))
    error_message = "Name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "base_label" {
  description = "Base label for consistent naming convention created from label module"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.base_label))
    error_message = "Base label must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "availability_zones" {
  description = "List of availability zones in which to create subnets"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two availability zones must be specified for high availability."
  }

  validation {
    condition     = alltrue([for az in var.availability_zones : can(regex("^[a-z]{2}-[a-z]+-[0-9][a-z]$", az))])
    error_message = "Availability zones must be in the format: region-az (e.g., us-east-1a)."
  }
}

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

variable "flow_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for VPC Flow Logs"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:logs:", var.flow_log_group_arn))
    error_message = "Flow log group ARN must be a valid CloudWatch Logs ARN."
  }
}
