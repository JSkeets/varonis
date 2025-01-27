variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "base_label" {
  description = "Base label for consistent naming convention created from label module"
  type = string
}

variable "availability_zones" {
  description = "List of availability zones in which to create subnets"
  type        = list(string)
}
