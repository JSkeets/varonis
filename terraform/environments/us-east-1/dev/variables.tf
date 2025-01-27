variable "region" {
  type        = string
  description = "The AWS region to deploy the infrastructure"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "The environment to deploy the infrastructure"
  default     = "dev"
}

variable "service" {
  type        = string
  description = "The service to deploy the infrastructure"
  default     = "pdf-service"
}

variable "allowed_cidrs" {
  type        = list(string)
  description = "The CIDR blocks allowed to access the API"
}