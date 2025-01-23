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
  subnet_tag_tier = "Private"

  vpc_name = var.vpc_name
  api_name = "restaurant-service"

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
  vpc_name           = var.vpc_name
  service            = var.service
  region             = var.region
  environment        = var.environment
  ecr_repository_url = module.restaurant_svc_ecr.repository_url
  function_name      = "restaurant-svc"
  image_tag          = "latest"
  memory_size        = 128
  subnet_tag_tier    = "Private"
  timeout            = 30
}


