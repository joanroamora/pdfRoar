output "originals_bucket_id" {
  description = "ID / Name of the originals S3 bucket"
  value       = aws_s3_bucket.originals.id
}

output "originals_bucket_arn" {
  description = "ARN of the originals S3 bucket"
  value       = aws_s3_bucket.originals.arn
}

output "originals_bucket_domain_name" {
  description = "Bucket domain name of the originals S3 bucket"
  value       = aws_s3_bucket.originals.bucket_domain_name
}

output "temp_bucket_id" {
  description = "ID / Name of the temporary S3 bucket"
  value       = aws_s3_bucket.temp.id
}

output "temp_bucket_arn" {
  description = "ARN of the temporary S3 bucket"
  value       = aws_s3_bucket.temp.arn
}

output "temp_bucket_domain_name" {
  description = "Bucket domain name of the temporary S3 bucket"
  value       = aws_s3_bucket.temp.bucket_domain_name
}
