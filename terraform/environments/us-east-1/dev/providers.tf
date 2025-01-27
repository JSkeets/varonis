terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "restaurant-svc-dev-terraform-state"
    key            = "environments/dev/ecr/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "restaurant-svc-dev-terraform-lock"
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = var.environment
      Service     = var.service
      Terraform   = "true"
    }
  }
}