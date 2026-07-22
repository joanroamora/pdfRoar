locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

# Fetch latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Bastion EC2 Instance
resource "aws_instance" "this" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.instance_profile_name
  key_name               = var.ssh_key_name != "" ? var.ssh_key_name : null

  root_block_device {
    volume_size           = 20 # 20 GB for OS + Docker + LGTM logs storage
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              set -e
              apt-get update -y
              apt-get install -y apt-transport-https ca-certificates curl software-properties-common git ansible docker.io
              systemctl enable docker
              systemctl start docker
              usermod -aG docker ubuntu
              echo "Bastion Host & LGTM server base initialized" > /var/log/bastion-bootstrap.log
              EOF

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-bastion-host"
    Role = "Bastion-LGTM-Ansible"
  })
}

# Persistent Elastic IP for Bastion
resource "aws_eip" "bastion_eip" {
  instance = aws_instance.this.id
  domain   = "vpc"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-bastion-eip"
  })
}
