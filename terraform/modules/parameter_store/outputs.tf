output "parameter_values" {
  description = "Map of parameter names to their values."
  value = {
    for k, v in aws_ssm_parameter.parameters : k => v.value
  }
  sensitive = true
} 