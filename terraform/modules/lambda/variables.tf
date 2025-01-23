variable "service" {
  type        = string
  description = "The name of the service"
}

variable "region" {
  type        = string
  description = "The region"
}

variable "environment" {
  type        = string
  description = "The environment"
}

variable "function_name" {
  type        = string
  description = "The name of the function"
}

variable "image_tag" {
  type        = string
  description = "The tag of the image"
}

variable "memory_size" {
  type        = number
  description = "The memory size of the function"
}

variable "timeout" {
  type        = number
  description = "The timeout of the function"
}

variable "ecr_repository_url" {
  type        = string
  description = "The URL of the ECR repository"
}

variable "vpc_name" {
  type        = string
  description = "The name of the VPC"
}

variable "subnet_tag_tier" {
  type        = string
  description = "The tag tier of the subnets (Private or Public)"
}