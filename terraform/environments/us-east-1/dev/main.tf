module "cloudwatch" {
  source = "../../../modules/cloudwatch"

  service           = var.service
  environment       = var.environment
  retention_in_days = 30
  enable_alarms     = true

  alarm_email_endpoints = [
    "jesseskeets@gmail.com",
  ]

  api_error_threshold    = 5
  lambda_error_threshold = 3
}

module "vpc" {
  source             = "../../../modules/vpc"
  name               = "restaurant"
  service            = "restaurant-svc"
  environment        = var.environment
  base_label         = "restaurant-svc-${var.environment}"
  availability_zones = ["us-east-1a", "us-east-1b"]
  flow_log_group_arn = module.cloudwatch.vpc_flow_log_group_arn
}

module "restaurant_svc_ecr" {
  source          = "../../../modules/ecr"
  service         = "restaurant-svc"
  environment     = var.environment
  repository_name = "restaurant-svc"
}

module "api_gateway" {
  source                   = "../../../modules/api_gateway"
  service                  = var.service
  region                   = var.region
  description              = "API Gateway for Restaurant Service"
  environment              = var.environment
  allowed_cidrs            = var.allowed_cidrs
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnet_ids
  api_name                 = "restaurant-service"
  cloudwatch_log_group_arn = module.cloudwatch.api_gateway_log_group_arn

  openapi_spec_path = "${path.module}/tpl/restaurant_svc_openapi.yaml"

  integrations = {
    "/restaurant/query" = {
      uri         = module.restaurant_svc_lambda.invoke_arn
      type        = "AWS_PROXY"
      http_method = "POST"
      timeout_ms  = 10000
    }
  }
}

locals {
  timestamp = formatdate("YYYYMMDD-HHmmss", timestamp())
}

module "restaurant_svc_lambda" {
  source                    = "../../../modules/lambda"
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnet_ids
  service                   = var.service
  region                    = var.region
  environment               = var.environment
  ecr_repository_url        = module.restaurant_svc_ecr.repository_url
  function_name             = "restaurant-svc"
  parameter_prefix          = "/${var.service}/${var.environment}"
  memory_size               = 128
  timeout                   = 29
  api_gateway_execution_arn = module.api_gateway.execution_arn
  image_tag                 = module.api_parameters.parameter_values["image_version"]

  dynamodb_table_name = module.restaurants_table.table_name
  dynamodb_table_arn  = module.restaurants_table.table_arn
  audit_table_name    = module.audit_table.table_name
  audit_table_arn     = module.audit_table.table_arn

  enable_dynamodb_access = true
}

module "restaurants_table" {
  source     = "../../../modules/dynamodb"
  name       = "restaurants"
  base_label = "restaurant-svc-${var.environment}"
  hash_key   = "restaurantId"

  vpc_id          = module.vpc.vpc_id
  route_table_ids = [module.vpc.private_route_table_id]

  billing_mode = "PAY_PER_REQUEST"
  attributes = [
    {
      name = "restaurantId"
      type = "S"
    },
    {
      name = "style"
      type = "S"
    },
    {
      name = "isVegetarian"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "StyleIndex"
      hash_key        = "style"
      projection_type = "ALL"
    },
    {
      name            = "VegetarianIndex"
      hash_key        = "isVegetarian"
      range_key       = "style"
      projection_type = "ALL"
    }
  ]

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
}

module "api_parameters" {
  source = "../../../modules/parameter_store"

  environment = var.environment
  service     = "restaurant-svc"

  parameters = {
    image_version = {
      value = "latest"
      type  = "String"
    }
  }
}

module "audit_table" {
  source = "../../../modules/dynamodb"

  base_label      = "${var.service}-${var.environment}"
  name            = "audit-logs"
  vpc_id          = module.vpc.vpc_id
  route_table_ids = [module.vpc.private_route_table_id]

  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "requestId"
  range_key    = "timestamp"

  attributes = [
    {
      name = "requestId"
      type = "S"
    },
    {
      name = "timestamp"
      type = "S"
    },
    {
      name = "date"
      type = "S"
    }
  ]

  global_secondary_indexes = [
    {
      name               = "DateIndex"
      hash_key           = "date"
      range_key          = "timestamp"
      projection_type    = "ALL"
      non_key_attributes = null
    }
  ]
}




