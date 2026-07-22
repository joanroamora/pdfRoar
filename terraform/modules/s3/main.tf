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

# Resource suffix to guarantee bucket name uniqueness across AWS
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# ==========================================
# 1. ORIGINALS BUCKET
# ==========================================
resource "aws_s3_bucket" "originals" {
  bucket        = "${local.name_prefix}-originals-${random_string.suffix.result}"
  force_destroy = var.environment == "dev" ? true : false

  tags = merge(local.common_tags, {
    Name         = "${local.name_prefix}-originals"
    Purpose      = "Storage of original user PDF documents"
    SecurityTier = "Private"
  })
}

resource "aws_s3_bucket_public_access_block" "originals" {
  bucket = aws_s3_bucket.originals.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "originals" {
  bucket = aws_s3_bucket.originals.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "originals" {
  bucket = aws_s3_bucket.originals.id

  versioning_configuration {
    status = var.enable_originals_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_cors_configuration" "originals" {
  bucket = aws_s3_bucket.originals.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "HEAD"]
    allowed_origins = var.cors_allowed_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Secure Policy: Require TLS/HTTPS
resource "aws_s3_bucket_policy" "originals_enforce_tls" {
  bucket = aws_s3_bucket.originals.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLSRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.originals.arn,
          "${aws_s3_bucket.originals.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# ==========================================
# 2. TEMPORARY FILES BUCKET
# ==========================================
resource "aws_s3_bucket" "temp" {
  bucket        = "${local.name_prefix}-temp-${random_string.suffix.result}"
  force_destroy = true

  tags = merge(local.common_tags, {
    Name         = "${local.name_prefix}-temp"
    Purpose      = "Storage of temporary processing PDF files and intermediate outputs"
    SecurityTier = "Private"
  })
}

resource "aws_s3_bucket_public_access_block" "temp" {
  bucket = aws_s3_bucket.temp.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "temp" {
  bucket = aws_s3_bucket.temp.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Automatic Cost Optimization: Expire objects after N days (default 1 day)
resource "aws_s3_bucket_lifecycle_configuration" "temp" {
  bucket = aws_s3_bucket.temp.id

  rule {
    id     = "auto-cleanup-temp-files"
    status = "Enabled"

    filter {}

    expiration {
      days = var.temp_file_expiration_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "temp" {
  bucket = aws_s3_bucket.temp.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = var.cors_allowed_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Secure Policy: Require TLS/HTTPS
resource "aws_s3_bucket_policy" "temp_enforce_tls" {
  bucket = aws_s3_bucket.temp.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLSRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.temp.arn,
          "${aws_s3_bucket.temp.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}
