output "k3s_master_instance_id" {
  description = "ID of the K3s Master EC2 instance"
  value       = aws_instance.k3s_master.id
}

output "k3s_master_private_ip" {
  description = "Private IP address of the K3s Master instance"
  value       = aws_instance.k3s_master.private_ip
}

output "pdf_worker_instance_id" {
  description = "ID of the PDF Worker EC2 instance"
  value       = aws_instance.pdf_worker.id
}

output "pdf_worker_private_ip" {
  description = "Private IP address of the PDF Worker instance"
  value       = aws_instance.pdf_worker.private_ip
}
