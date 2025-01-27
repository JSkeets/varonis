module "vpc" {
  source = "../../../modules/vpc"
  name   = "restaurant"
  base_label = "restaurant-svc-${var.environment}"
  availability_zones = ["us-east-1a", "us-east-1b"]
}

module "restaurant_svc_ecr" {
  source          = "../../../modules/ecr"
  service         = "restaurant-svc"
  environment     = var.environment
  repository_name = "restaurant-svc"
}

module "api_gateway" {
  source          = "../../../modules/api_gateway"
  service         = var.service
  region          = var.region
  description     = "API Gateway for Restaurant Service"
  environment     = var.environment
  allowed_cidrs   = var.allowed_cidrs
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  api_name        = "restaurant-service"

  openapi_spec_path = "${path.module}/tpl/restaurant_svc_openapi.yaml"

  integrations = {
    "/restaurant/web" = {
      uri         = module.restaurant_svc_lambda.invoke_arn
      type        = "AWS_PROXY"
      http_method = "POST"
      timeout_ms  = 10000
    }
  }
}

module "restaurant_svc_lambda" {
  source             = "../../../modules/lambda"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  service            = var.service
  region             = var.region
  environment        = var.environment
  ecr_repository_url = module.restaurant_svc_ecr.repository_url
  function_name      = "restaurant-svc"
  image_tag          = "latest"
  memory_size        = 128
  timeout            = 30
  api_gateway_execution_arn = module.api_gateway.execution_arn
}


