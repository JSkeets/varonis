locals {
  # OpenAPI spec templating
  openapi_spec = templatefile(var.openapi_spec_path, {
    integrations = var.integrations
  })

  # Resource policy for API Gateway - Allow specific CIDRs
  resource_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "execute-api:Invoke"
        Resource  = "execute-api:/*"
        Condition = {
          IpAddress = {
            "aws:SourceIp" : var.allowed_cidrs
          }
        }
      },
      {
        Effect    = "Deny"
        Principal = "*"
        Action    = "execute-api:Invoke"
        Resource  = "execute-api:/*"
        Condition = {
          NotIpAddress = {
            "aws:SourceIp" : var.allowed_cidrs
          }
        }
      }
    ]
  })
}