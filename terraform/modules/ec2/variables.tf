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

variable "private_subnet_ids" {
  description = "List of Private Subnet IDs"
  type        = list(string)
}

variable "k3s_security_group_id" {
  description = "Security Group ID for K3s App Node"
  type        = string
}

variable "worker_security_group_id" {
  description = "Security Group ID for PDF Worker Node"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM Instance Profile Name for EC2 instances"
  type        = string
}

variable "k3s_instance_type" {
  description = "EC2 Instance type for K3s Master (Frontend + API Gateway)"
  type        = string
  default     = "t3.small"
}

variable "worker_instance_type" {
  description = "EC2 Instance type for heavy PDF Worker"
  type        = string
  default     = "t3.medium"
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
