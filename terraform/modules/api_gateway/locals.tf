locals {
  # OpenAPI spec templating
  openapi_spec = templatefile(var.openapi_spec_path, {
    integrations = var.integrations
  })

  # Resource policy for API Gateway
  resource_policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect    = "Deny"
        Principal = "*"
        Action    = "execute-api:Invoke"
        Resource  = "execute-api:/*"
      },
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "execute-api:Invoke"
        Resource  = "execute-api:/*"
        Condition = {
          StringEquals = {
            "aws:SourceVpce" : aws_vpc_endpoint.api_gateway.id
          }
        }
      }],
      var.allowed_cidrs != null ? [
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
        }
      ] : []
    )
  })
}