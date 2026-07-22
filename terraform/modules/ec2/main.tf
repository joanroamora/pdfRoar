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

# ==========================================
# 1. K3S MASTER NODE (Frontend + API Gateway + Light Microservices)
# ==========================================
resource "aws_instance" "k3s_master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.k3s_instance_type
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [var.k3s_security_group_id]
  iam_instance_profile   = var.instance_profile_name
  key_name               = var.ssh_key_name != "" ? var.ssh_key_name : null

  root_block_device {
    volume_size           = 25
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              set -e
              apt-get update -y
              apt-get install -y curl ca-certificates open-iscsi nfs-common
              echo "K3s Master node prerequisites ready" > /var/log/k3s-master-bootstrap.log
              EOF

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-k3s-master"
    Role = "K3s-Master-APIGateway"
  })
}

# ==========================================
# 2. PDF WORKER NODE (On-Demand Heavy PDF Editor)
# ==========================================
resource "aws_instance" "pdf_worker" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.worker_instance_type
  subnet_id              = var.private_subnet_ids[length(var.private_subnet_ids) > 1 ? 1 : 0]
  vpc_security_group_ids = [var.worker_security_group_id]
  iam_instance_profile   = var.instance_profile_name
  key_name               = var.ssh_key_name != "" ? var.ssh_key_name : null

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              set -e
              apt-get update -y
              apt-get install -y curl ca-certificates python3 python3-pip docker.io
              systemctl enable docker
              systemctl start docker
              echo "PDF Worker node initialized" > /var/log/worker-bootstrap.log
              EOF

  tags = merge(local.common_tags, {
    Name          = "${local.name_prefix}-pdf-worker"
    Role          = "PDF-Heavy-Editor-Worker"
    AutoStartStop = "true"
    Schedule      = "OnDemand"
  })
}
