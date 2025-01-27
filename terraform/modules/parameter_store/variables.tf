variable "environment" {
  description = "The deployment environment (e.g., 'dev', 'prod')"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "parameters" {
  description = "Map of parameters to create"
  type = map(object({
    value     = string
    type      = string # "String" or "SecureString"
    overwrite = optional(bool, true)
  }))

  validation {
    condition     = alltrue([for k, v in var.parameters : contains(["String", "SecureString", "StringList"], v.type)])
    error_message = "Parameter type must be one of: String, SecureString, or StringList."
  }

  validation {
    condition     = alltrue([for k, v in var.parameters : length(k) <= 128])
    error_message = "Parameter names must not exceed 128 characters."
  }

  validation {
    condition     = alltrue([for k, v in var.parameters : can(regex("^[a-zA-Z0-9_.-/]+$", k))])
    error_message = "Parameter names can only contain alphanumeric characters, periods, dashes, underscores, and forward slashes."
  }
}

variable "service" {
  description = "Service name for parameter grouping"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.service))
    error_message = "Service name must contain only lowercase letters, numbers, and hyphens."
  }
}

