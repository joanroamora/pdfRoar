variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "pdfroar"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "single_nat_gateway" {
  description = "Enable single NAT Gateway to optimize AWS cost"
  type        = bool
  default     = true
}

variable "temp_file_expiration_days" {
  description = "Lifecycle policy: auto-delete temp files after N days"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Global tags to apply to all resources"
  type        = map(string)
  default = {
    Project      = "pdfRoar"
    ManagedBy    = "Terraform"
    Architecture = "CloudNative-CostOptimized"
  }
}
