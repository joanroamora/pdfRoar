terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # Recommended backend setup for production (uncomment when S3+DynamoDB state backend is ready)
  # backend "s3" {
  #   bucket         = "pdfroar-tfstate-bucket"
  #   key            = "prod/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "pdfroar-tfstate-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      var.tags,
      {
        Environment = var.environment
      }
    )
  }
}

# --- Module: VPC ---
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = true
  single_nat_gateway   = var.single_nat_gateway
  tags                 = var.tags
}

# --- Module: S3 ---
module "s3" {
  source = "./modules/s3"

  project_name              = var.project_name
  environment               = var.environment
  temp_file_expiration_days = var.temp_file_expiration_days
  tags                      = var.tags
}
