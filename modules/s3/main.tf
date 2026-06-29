data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "alb_logs_s3" {
  bucket = "cloudnorth-alb-logs-${data.aws_caller_identity.current.account_id}"
  
  tags = {
    Name        = "cloudnorth-alb-logs"
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "app_assets_s3" {
  bucket = "cloudnorth-app-assets-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "cloudnorth-app-assets"
    Environment = var.environment
  }
}

# Encryption — both buckets
resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs_s3.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_assets" {
  bucket = aws_s3_bucket.app_assets_s3.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access — both buckets
resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket                  = aws_s3_bucket.alb_logs_s3.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "app_assets" {
  bucket                  = aws_s3_bucket.app_assets_s3.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle rule — ALB logs bucket, delete after 90 days
resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs_s3.id

  rule {
    id     = "delete-after-90-days"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

# Bucket policy — allows ALB to write access logs
resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs_s3.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "logdelivery.elasticloadbalancing.amazonaws.com"
      }
      Action   = "s3:PutObject"
      Resource = "${aws_s3_bucket.alb_logs_s3.arn}/alb/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      Condition = {
        StringEquals = {
          "s3:x-amz-acl" = "bucket-owner-full-control"
        }
      }
    }]
  })
}