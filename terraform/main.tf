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

# --- Module 1: VPC ---
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

# --- Module 2: S3 ---
module "s3" {
  source = "./modules/s3"

  project_name              = var.project_name
  environment               = var.environment
  temp_file_expiration_days = var.temp_file_expiration_days
  tags                      = var.tags
}

# --- Module 3: Security & IAM ---
module "security" {
  source = "./modules/security"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  originals_bucket_arn  = module.s3.originals_bucket_arn
  temp_bucket_arn       = module.s3.temp_bucket_arn
  allowed_ssh_cidrs     = var.allowed_ssh_cidrs
  allowed_grafana_cidrs = var.allowed_ssh_cidrs
  tags                  = var.tags
}

# --- Module 4: Bastion Host ---
module "bastion" {
  source = "./modules/bastion"

  project_name          = var.project_name
  environment           = var.environment
  subnet_id             = module.vpc.public_subnet_ids[0]
  security_group_id     = module.security.bastion_security_group_id
  instance_profile_name = module.security.ec2_instance_profile_name
  instance_type         = var.bastion_instance_type
  ssh_key_name          = var.ssh_key_name
  tags                  = var.tags
}

# --- Module 5: EC2 Compute (K3s Master + On-Demand PDF Worker) ---
module "ec2" {
  source = "./modules/ec2"

  project_name             = var.project_name
  environment              = var.environment
  private_subnet_ids       = module.vpc.private_subnet_ids
  k3s_security_group_id    = module.security.k3s_security_group_id
  worker_security_group_id = module.security.worker_security_group_id
  instance_profile_name    = module.security.ec2_instance_profile_name
  k3s_instance_type        = var.k3s_instance_type
  worker_instance_type     = var.worker_instance_type
  ssh_key_name             = var.ssh_key_name
  tags                     = var.tags
}
