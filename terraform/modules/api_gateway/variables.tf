variable "service" {
  type        = string
  description = "The name of the service"
}

variable "environment" {
  type        = string
  description = "The environment"
}

variable "openapi_spec_path" {
  type        = string
  description = "The path to the OpenAPI spec"
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
    timeout_ms  = optional(number, 29000)
  }))
  description = "Map of API Gateway integrations configurations"
}

variable "description" {
  type        = string
  description = "The description of the API"
}

variable "allowed_cidrs" {
  type        = list(string)
  description = "The CIDR blocks allowed to access the API"
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
