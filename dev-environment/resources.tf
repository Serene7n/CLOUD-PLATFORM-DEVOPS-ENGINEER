resource "aws_s3_bucket" "bucket1" {
  bucket = "cloud-job-2026-1"

  # Checkov skip comments MUST be placed inside the resource block
  #checkov:skip=CKV_AWS_144: "Cross-region replication not required for non-production bucket"
  #checkov:skip=CKV2_AWS_62: "Event notifications not needed for dev environment"
  #checkov:skip=CKV2_AWS_61: "Lifecycle configuration not required for testing"
  #checkov:skip=CKV_AWS_18: "Access logging disabled for dev environment"
  #checkov:skip=CKV2_AWS_6: "Bucket is explicitly intended for public web/asset access"
  #checkov:skip=CKV_AWS_20: "Public read policy is required for public bucket use case"

  tags = {
    Name        = "bucket1"
    Environment = "Dev"
  }
}

# Enable Versioning
resource "aws_s3_bucket_versioning" "bucket1" {
  bucket = aws_s3_bucket.bucket1.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable Encryptioin
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket1" {
  bucket = aws_s3_bucket.bucket1.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

# Attach Public Access Block to resolve CKV2_AWS_6
resource "aws_s3_bucket_public_access_block" "bucket1_public_access" {
  bucket = aws_s3_bucket.bucket1.id

  #checkov:skip=CKV_AWS_53: "Bucket is intentionally configured for public access"
  #checkov:skip=CKV_AWS_54: "Bucket policy must allow public read access"
  #checkov:skip=CKV_AWS_55: "Public ACLs allowed for public assets"
  #checkov:skip=CKV_AWS_56: "Restricting public buckets disabled for public web access"

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 2. Attach a bucket policy allowing anonymous read access
resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket = aws_s3_bucket.bucket1.id

  # Ensures public access settings are unblocked BEFORE applying the policy
  depends_on = [aws_s3_bucket_public_access_block.bucket1_public_access]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.bucket1.arn}/*"
      }
    ]
  })
}
