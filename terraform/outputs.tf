output "vpc_id" {
  description = "ID of the VPC created"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "originals_bucket_name" {
  description = "Name of the S3 bucket for original files"
  value       = module.s3.originals_bucket_id
}

output "temp_bucket_name" {
  description = "Name of the S3 bucket for temporary files"
  value       = module.s3.temp_bucket_id
}
