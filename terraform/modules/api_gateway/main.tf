resource "aws_vpc_endpoint" "api_gateway" {
  vpc_id              = data.aws_vpc.selected.id
  service_name        = "com.amazonaws.${var.region}.execute-api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = data.aws_subnets.private.ids

  security_group_ids = [aws_security_group.api_gateway_endpoint.id]

  tags = {
    Name = "${var.service}-${var.environment}-api-gateway-endpoint"
  }
}

resource "aws_security_group" "api_gateway_endpoint" {
  name        = "${var.service}-${var.environment}-api-gateway-endpoint"
  description = "Security group for API Gateway VPC endpoint"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  tags = {
    Name = "${var.service}-${var.environment}-api-gateway-endpoint-sg"
  }
}

resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.service}-${var.environment}-${var.api_name}"
  description = var.description
  body        = local.openapi_spec

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  policy = local.resource_policy
}


resource "aws_api_gateway_deployment" "this" {
  depends_on  = [aws_api_gateway_rest_api.this]
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha256(local.openapi_spec)
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  stage_name    = var.environment
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
}
