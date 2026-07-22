variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "pdfroar"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "temp_file_expiration_days" {
  description = "Number of days before temporary files in S3 are automatically deleted"
  type        = number
  default     = 1
}

variable "enable_originals_versioning" {
  description = "Enable versioning on the original files bucket"
  type        = bool
  default     = true
}

variable "cors_allowed_origins" {
  description = "List of allowed origins for S3 CORS"
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
