terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "local" {
    path = "terraform.tfstate"
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