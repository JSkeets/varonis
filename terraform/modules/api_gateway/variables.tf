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

variable "vpc_name" {
  type        = string
  description = "The name of the VPC"
}

variable "subnet_tag_tier" {
  type        = string
  description = "The tag tier of the subnets (Private or Public)"
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
