variable "name" {
  description = "Name of the DynamoDB table"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]+$", var.name))
    error_message = "Table name must contain only alphanumeric characters, dots, hyphens, and underscores."
  }
}

variable "base_label" {
  description = "Base label for resource naming"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.base_label))
    error_message = "Base label must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "hash_key" {
  description = "Hash key for the table"
  type        = string
}

variable "attributes" {
  description = "List of DynamoDB attributes"
  type = list(object({
    name = string
    type = string
  }))

  validation {
    condition     = alltrue([for attr in var.attributes : contains(["S", "N", "B"], attr.type)])
    error_message = "Attribute type must be one of: S (string), N (number), or B (binary)."
  }
}

variable "global_secondary_indexes" {
  description = "List of global secondary indexes"
  type = list(object({
    name               = string
    hash_key          = string
    range_key         = optional(string)
    projection_type   = string
    non_key_attributes = optional(list(string), [])
  }))
  default = []

  validation {
    condition     = alltrue([for idx in var.global_secondary_indexes : contains(["ALL", "KEYS_ONLY", "INCLUDE"], idx.projection_type)])
    error_message = "Projection type must be one of: ALL, KEYS_ONLY, or INCLUDE."
  }
}

variable "billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "Billing mode must be either PROVISIONED or PAY_PER_REQUEST."
  }
}

variable "stream_enabled" {
  description = "Enable DynamoDB Streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "When stream is enabled, controls how much information is written to stream"
  type        = string
  default     = null

  validation {
    condition     = var.stream_view_type == null ? true : contains(["NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES", "KEYS_ONLY"], var.stream_view_type)
    error_message = "Stream view type must be one of: NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES, or KEYS_ONLY."
  }
}

variable "vpc_id" {
  description = "ID of the VPC where the DynamoDB endpoint will be created"
  type        = string
}

variable "route_table_ids" {
  description = "List of route table IDs to associate with the DynamoDB endpoint"
  type        = list(string)
}

variable "range_key" {
  description = "Range key for the table"
  type        = string
  default     = null
} 