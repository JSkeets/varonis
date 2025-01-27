

variable "environment" {
  description = "The deployment environment (e.g., 'dev', 'prod')"
  type        = string
}

variable "parameters" {
  description = "Map of parameters to create"
  type = map(object({
    value     = string
    type      = string # "String" or "SecureString"
    overwrite = optional(bool, true)
  }))
}

variable "service" {
  description = "Service name for parameter grouping"
  type        = string
}

