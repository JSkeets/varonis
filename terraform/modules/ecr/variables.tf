variable "service" {
  type        = string
  description = "The name of the service"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.service))
    error_message = "Service name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  type        = string
  description = "The environment (e.g., dev, staging, prod)"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "repository_name" {
  type        = string
  description = "The name of the ECR repository"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.repository_name))
    error_message = "Repository name must start with a letter and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "image_retention_count" {
  description = "Number of images to keep in the repository"
  type        = number
  default     = 5

  validation {
    condition     = var.image_retention_count >= 1 && var.image_retention_count <= 1000
    error_message = "Image retention count must be between 1 and 1000."
  }
}