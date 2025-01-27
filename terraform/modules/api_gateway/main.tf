resource "aws_vpc_endpoint" "api_gateway" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.execute-api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = var.subnet_ids

  security_group_ids = [aws_security_group.api_gateway_endpoint.id]

  tags = {
    Name = "${var.service}-${var.environment}-api-gateway-endpoint"
  }
}

resource "aws_security_group" "api_gateway_endpoint" {
  name        = "${var.service}-${var.environment}-api-gateway-endpoint"
  description = "Security group for API Gateway VPC endpoint"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
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
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id  = aws_api_gateway_rest_api.this.id
  stage_name   = var.environment
}
