output "bastion_security_group_id" {
  description = "ID of the Bastion security group"
  value       = aws_security_group.bastion.id
}

output "k3s_security_group_id" {
  description = "ID of the K3s cluster security group"
  value       = aws_security_group.k3s.id
}

output "worker_security_group_id" {
  description = "ID of the PDF Worker security group"
  value       = aws_security_group.worker.id
}

output "ec2_instance_profile_name" {
  description = "Name of the EC2 IAM Instance Profile"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}

output "ec2_instance_profile_arn" {
  description = "ARN of the EC2 IAM Instance Profile"
  value       = aws_iam_instance_profile.ec2_instance_profile.arn
}

output "ec2_role_arn" {
  description = "ARN of the EC2 IAM Role"
  value       = aws_iam_role.ec2_role.arn
}
