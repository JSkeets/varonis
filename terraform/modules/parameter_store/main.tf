resource "aws_ssm_parameter" "parameters" {
  for_each = var.parameters

  name  = "/${var.service}/${var.environment}/${each.key}"
  type  = each.value.type
  value = each.value.value

  tags = {
    Environment = var.environment
    Service     = var.service
  }

  lifecycle {
    ignore_changes = [
      overwrite,  # Ignore future changes to overwrite
    ]
  }
}
