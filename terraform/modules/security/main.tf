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

# ==========================================
# IAM ROLES & POLICIES (S3 & EC2 Management)
# ==========================================

resource "aws_iam_role" "ec2_role" {
  name = "${local.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Policy to allow S3 access & EC2 self-start/stop for PDF Worker management
resource "aws_iam_policy" "ec2_app_policy" {
  name        = "${local.name_prefix}-ec2-policy"
  description = "Permissions for EC2 instances to access S3 buckets and manage EC2 Worker power state"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.originals_bucket_arn,
          "${var.originals_bucket_arn}/*",
          var.temp_bucket_arn,
          "${var.temp_bucket_arn}/*"
        ]
      },
      {
        Sid    = "WorkerEC2Control"
        Effect = "Allow"
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus"
        ]
        Resource = "*"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ec2_policy_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_app_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${local.name_prefix}-instance-profile"
  role = aws_iam_role.ec2_role.name

  tags = local.common_tags
}

# ==========================================
# SECURITY GROUPS
# ==========================================

# 1. Bastion Host Security Group
resource "aws_security_group" "bastion" {
  name        = "${local.name_prefix}-bastion-sg"
  description = "Security Group for Bastion Host & LGTM Observability Stack"
  vpc_id      = var.vpc_id

  # SSH Access
  ingress {
    description = "SSH from allowed IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  # Grafana Access (LGTM Stack)
  ingress {
    description = "Grafana Web Dashboard"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.allowed_grafana_cidrs
  }

  # Prometheus / Loki / Tempo internal ports if needed
  ingress {
    description = "Prometheus Server"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = var.allowed_grafana_cidrs
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-bastion-sg"
  })
}

# 2. K3s Master / API Gateway Security Group
resource "aws_security_group" "k3s" {
  name        = "${local.name_prefix}-k3s-sg"
  description = "Security Group for K3s App Node and API Gateway"
  vpc_id      = var.vpc_id

  # Public Web Traffic (HTTP/HTTPS)
  ingress {
    description = "HTTP Public Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS Public Access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH & K3s API Management from Bastion Host
  ingress {
    description     = "SSH from Bastion Host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    description     = "K3s Kubernetes API from Bastion Host"
    from_port       = 6443
    to_port         = 6443
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # Metrics scraping from Bastion (Prometheus / Alloy / Vector)
  ingress {
    description     = "Node Exporter / Metrics from Bastion"
    from_port       = 9100
    to_port         = 9100
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-k3s-sg"
  })
}

# 3. PDF Worker Security Group (On-Demand Editing Instance)
resource "aws_security_group" "worker" {
  name        = "${local.name_prefix}-worker-sg"
  description = "Security Group for On-Demand Heavy PDF Worker"
  vpc_id      = var.vpc_id

  # Internal API Access from K3s API Gateway
  ingress {
    description     = "PDF Editor Microservice API from K3s Gateway"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.k3s.id]
  }

  # SSH & Observability Management from Bastion Host
  ingress {
    description     = "SSH from Bastion Host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    description     = "Node Exporter from Bastion"
    from_port       = 9100
    to_port         = 9100
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-worker-sg"
  })
}
