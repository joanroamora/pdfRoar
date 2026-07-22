output "instance_id" {
  description = "ID of the Bastion EC2 instance"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public Elastic IP address of the Bastion Host"
  value       = aws_eip.bastion_eip.public_ip
}

output "private_ip" {
  description = "Private IP address of the Bastion Host"
  value       = aws_instance.this.private_ip
}
