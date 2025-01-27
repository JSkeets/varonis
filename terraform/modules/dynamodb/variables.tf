variable "name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "base_label" {
  description = "Base label for consistent naming convention"
  type        = string
}

variable "hash_key" {
  description = "The attribute to use as the hash (partition) key"
  type        = string
}

variable "attributes" {
  description = "List of nested attribute definitions. Only required for hash_key and range_key attributes"
  type = list(object({
    name = string
    type = string
  }))
}

variable "global_secondary_indexes" {
  description = "List of global secondary indexes to create"
  type = list(object({
    name               = string
    hash_key          = string
    range_key         = optional(string)
    projection_type   = string
    non_key_attributes = optional(list(string))
  }))
  default = []
}

variable "billing_mode" {
  description = "Controls how you are charged for read and write throughput. Valid values are PROVISIONED and PAY_PER_REQUEST"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "stream_enabled" {
  description = "Indicates whether Streams are to be enabled (true) or disabled (false)"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "When an item in the table is modified, StreamViewType determines what information is written to the table's stream"
  type        = string
  default     = null
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
  description = "The range key for the DynamoDB table"
  type        = string
  default     = null 
} 