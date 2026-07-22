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
              apt-get install -y apt-transport-https ca-certificates curl software-properties-common git ansible docker.io nginx python3-pip build-essential libmupdf-dev
              systemctl enable docker nginx
              systemctl start docker nginx
              usermod -aG docker ubuntu

              # Install Python PDF processing dependencies
              pip3 install pymupdf fastapi "uvicorn[standard]" boto3 prometheus-client python-multipart pydantic

              # Remove default Nginx debian welcome page
              rm -f /var/www/html/index.nginx-debian.html

              # Clone main repository for Frontend & Backend Engine
              rm -rf /tmp/pdfRoar
              git clone https://github.com/joanroamora/pdfRoar.git /tmp/pdfRoar
              cp -rf /tmp/pdfRoar/frontend/* /var/www/html/

              # Start Consolidated Backend Engine on port 8000
              cd /tmp/pdfRoar
              nohup uvicorn app_main:app --host 0.0.0.0 --port 8000 > /var/log/pdfroar-backend.log 2>&1 &

              cat << 'NGINX_CONF' > /etc/nginx/sites-available/default
              server {
                  listen 80 default_server;
                  listen [::]:80 default_server;

                  root /var/www/html;
                  index index.html;

                  client_max_body_size 100M;

                  location / {
                      try_files $uri $uri/ /index.html;
                  }

                  location /api/ {
                      proxy_pass http://127.0.0.1:8000;
                      proxy_set_header Host $host;
                      proxy_set_header X-Real-IP $remote_addr;
                      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  }
              }
              NGINX_CONF

              systemctl reload nginx
              echo "pdfRoar Full Stack Active (Font & UI Split Update)" > /var/log/bastion-bootstrap.log
              EOF

  user_data_replace_on_change = true

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
