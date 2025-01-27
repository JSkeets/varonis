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

variable "retention_in_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.retention_in_days)
    error_message = "Retention days must be one of: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653."
  }
}

variable "alarm_email_endpoints" {
  description = "List of email addresses to notify for alarms"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for email in var.alarm_email_endpoints : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))])
    error_message = "All elements must be valid email addresses."
  }
}

variable "enable_alarms" {
  description = "Enable CloudWatch alarms"
  type        = bool
  default     = true
}

variable "api_error_threshold" {
  description = "Threshold for API Gateway 5XX errors"
  type        = number
  default     = 5

  validation {
    condition     = var.api_error_threshold > 0
    error_message = "API error threshold must be greater than 0."
  }
}

variable "lambda_error_threshold" {
  description = "Threshold for Lambda function errors"
  type        = number
  default     = 3

  validation {
    condition     = var.lambda_error_threshold > 0
    error_message = "Lambda error threshold must be greater than 0."
  }
} 