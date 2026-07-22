variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "pdfroar"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "subnet_id" {
  description = "Public Subnet ID where Bastion Host will be deployed"
  type        = string
}

variable "security_group_id" {
  description = "Bastion Security Group ID"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM Instance Profile Name for Bastion Host"
  type        = string
}

variable "instance_type" {
  description = "EC2 Instance type for Bastion Host (cost-optimized t3.small / t3.micro)"
  type        = string
  default     = "t3.small"
}

variable "ssh_key_name" {
  description = "AWS SSH Key Pair Name for EC2 instances"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
