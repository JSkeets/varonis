terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "restaurant-svc-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "restaurant-svc-terraform-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = var.environment
      Service     = var.service
      ManagedBy   = "terraform"
    }
  }
}

module "cloudwatch" {
  source = "../../../modules/cloudwatch"

  service           = var.service
  environment       = var.environment
  retention_in_days = 90
  enable_alarms     = true

  alarm_email_endpoints = [
    "jesseskeets@gmail.com",
  ]

  api_error_threshold    = 3
  lambda_error_threshold = 2
}

module "vpc" {
  source             = "../../../modules/vpc"
  name               = "restaurant"
  service            = "restaurant-svc"
  environment        = var.environment
  base_label         = "restaurant-svc-${var.environment}"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"] # Three AZs for prod
  flow_log_group_arn = module.cloudwatch.vpc_flow_log_group_arn
}

module "restaurant_svc_ecr" {
  source          = "../../../modules/ecr"
  service         = "restaurant-svc"
  environment     = var.environment
  repository_name = "restaurant-svc-${var.environment}-restaurant-svc"
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
      timeout_ms  = 29000 # Increased timeout for prod
    }
  }
}

module "api_parameters" {
  source = "../../../modules/ssm"

  service     = var.service
  environment = var.environment

  parameters = {
    image_version = "latest"
  }
}

module "restaurant_svc_lambda" {
  source                    = "../../../modules/lambda"
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnet_ids
  service                   = var.service
  region                    = var.region
  environment               = var.environment
  ecr_repository_url        = module.restaurant_svc_ecr.repository_url
  function_name             = "restaurant-${var.environment}-restaurant-svc"
  parameter_prefix          = "/${var.service}/${var.environment}"
  memory_size               = 256 # More memory for prod
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

  billing_mode = "PROVISIONED" # Switch to provisioned for prod


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
      read_capacity   = 10
      write_capacity  = 5
    },
    {
      name            = "VegetarianIndex"
      hash_key        = "isVegetarian"
      range_key       = "style"
      projection_type = "ALL"
      read_capacity   = 10
      write_capacity  = 5
    }
  ]

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"


}

module "audit_table" {
  source     = "../../../modules/dynamodb"
  name       = "audit"
  base_label = "restaurant-svc-${var.environment}"
  hash_key   = "id"

  vpc_id          = module.vpc.vpc_id
  route_table_ids = [module.vpc.private_route_table_id]

  billing_mode = "PROVISIONED"

  attributes = [
    {
      name = "id"
      type = "S"
    },
    {
      name = "timestamp"
      type = "N"
    }
  ]

  global_secondary_indexes = [
    {
      name            = "TimestampIndex"
      hash_key        = "timestamp"
      projection_type = "ALL"
      read_capacity   = 5
      write_capacity  = 5
    }
  ]

}

output "api_gateway_url" {
  description = "API Gateway URL"
  value       = module.api_gateway.api_gateway_url
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private Subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public Subnet IDs"
  value       = module.vpc.public_subnet_ids
} 