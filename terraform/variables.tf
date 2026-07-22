variable "aws_region" {
  description = "AWS region to deploy resources in (us-east-1 for dev, us-east-2 for staging, us-west-2 for prod)"
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
  default     = "dev"
}

variable "enable_deployment" {
  description = "Flag to enable resource provisioning for the environment"
  type        = bool
  default     = true
}

variable "launch_safety_lock" {
  description = "Safety lock flag to prevent accidental provisioning in non-dev multi-region environments (staging/prod)"
  type        = bool
  default     = false
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

variable "ssh_key_name" {
  description = "AWS Key Pair Name for SSH access"
  type        = string
  default     = ""
}

variable "bastion_instance_type" {
  description = "Instance type for Bastion Host & LGTM"
  type        = string
  default     = "t3.small"
}

variable "k3s_instance_type" {
  description = "Instance type for K3s Master Node"
  type        = string
  default     = "t3.small"
}

variable "worker_instance_type" {
  description = "Instance type for On-Demand PDF Worker"
  type        = string
  default     = "t3.medium"
}

variable "allowed_ssh_cidrs" {
  description = "Allowed CIDRs for SSH access to Bastion Host"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Global tags to apply to all resources"
  type        = map(string)
  default = {
    Project      = "pdfRoar"
    ManagedBy    = "Terraform"
    Architecture = "MultiEnvironment-CostOptimized"
  }
}
