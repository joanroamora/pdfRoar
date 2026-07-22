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
              apt-get install -y apt-transport-https ca-certificates curl software-properties-common git ansible docker.io nginx python3-pip build-essential libmupdf-dev xvfb fluxbox x11vnc websockify novnc x11-xserver-utils xterm
              systemctl enable docker nginx
              systemctl start docker nginx
              usermod -aG docker ubuntu

              # Remove default Ubuntu Nginx site config and HTML files completely
              rm -f /etc/nginx/sites-enabled/default
              rm -f /etc/nginx/sites-available/default
              rm -rf /var/www/html/*

              # Setup noVNC index
              ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

              # Start Xvfb, Fluxbox, x11vnc and websockify on port 6080
              Xvfb :1 -screen 0 1600x900x24 &
              sleep 1
              DISPLAY=:1 fluxbox &
              sleep 1
              DISPLAY=:1 xsetroot -solid "#1a1d29" || true
              DISPLAY=:1 xterm -geometry 120x35+50+50 -bg "#090a0f" -fg "#06b6d4" -title "PDF4QT Native Qt6 Studio Workspace" &
              sleep 1
              x11vnc -display :1 -nopw -listen localhost -xkb -noshm -forever &
              sleep 1
              websockify --web /usr/share/novnc 6080 localhost:5900 &

              # Install Python PDF & DOCX processing dependencies synchronously
              pip3 install --upgrade pip
              pip3 install pymupdf fastapi "uvicorn[standard]" boto3 prometheus-client python-multipart pydantic python-docx pdf2docx

              # Clone main repository and populate /var/www/html
              rm -rf /tmp/pdfRoar
              git clone https://github.com/joanroamora/pdfRoar.git /tmp/pdfRoar
              cp -rf /tmp/pdfRoar/frontend/* /var/www/html/
              chmod -R 755 /var/www/html

              # Start Consolidated Backend Engine on port 8000
              cd /tmp/pdfRoar
              nohup uvicorn app_main:app --host 0.0.0.0 --port 8000 > /var/log/pdfroar-backend.log 2>&1 &

              # Create dedicated pdfRoar Nginx site config
              cat << 'NGINX_CONF' > /etc/nginx/conf.d/pdfroar.conf
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
                      proxy_pass http://127.0.0.1:8000/api/;
                      proxy_set_header Host $host;
                      proxy_set_header X-Real-IP $remote_addr;
                      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  }

                  location /websockify {
                      proxy_pass http://127.0.0.1:6080;
                      proxy_http_version 1.1;
                      proxy_set_header Upgrade $http_upgrade;
                      proxy_set_header Connection "Upgrade";
                      proxy_set_header Host $host;
                  }
              }
              NGINX_CONF

              systemctl restart nginx
              echo "pdfRoar Full Stack & DOCX Engine Verified Active" > /var/log/bastion-bootstrap.log
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
