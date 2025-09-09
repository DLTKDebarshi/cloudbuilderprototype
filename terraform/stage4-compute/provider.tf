# Terraform and AWS provider configuration

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    # Backend configuration will be provided via command line
    # -backend-config="bucket=cloudbuilderprototype-tfstate-prod"
    # -backend-config="key=stage4-compute/terraform.tfstate"
    # -backend-config="region=us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Stage       = "compute"
    }
  }
}