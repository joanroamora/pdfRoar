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

output "bastion_public_ip" {
  description = "Elastic Public IP of Bastion Host & LGTM Server"
  value       = module.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Private IP of Bastion Host"
  value       = module.bastion.private_ip
}

output "k3s_master_private_ip" {
  description = "Private IP of K3s Master Node"
  value       = module.ec2.k3s_master_private_ip
}

output "pdf_worker_private_ip" {
  description = "Private IP of On-Demand PDF Worker"
  value       = module.ec2.pdf_worker_private_ip
}

output "pdf_worker_instance_id" {
  description = "EC2 Instance ID of On-Demand PDF Worker for Start/Stop control"
  value       = module.ec2.pdf_worker_instance_id
}
