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

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "originals_bucket_arn" {
  description = "ARN of the S3 originals bucket for IAM policy"
  type        = string
}

variable "temp_bucket_arn" {
  description = "ARN of the S3 temp bucket for IAM policy"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed for SSH access to Bastion"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_grafana_cidrs" {
  description = "CIDR blocks allowed for Grafana web access on Bastion"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
