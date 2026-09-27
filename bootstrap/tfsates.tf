terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "eu-west-1"
  profile = "Dev"
}

# 1. S3 Bucket for State Storage
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "cloud-platform-tfstate-eu-west-1-dev"
  force_destroy = false

  # Suppress optional/architectural Checkov warnings not needed for dev
  #checkov:skip=CKV_AWS_144: "Cross-region replication not required for dev bucket"
  #checkov:skip=CKV2_AWS_62: "Event notifications not required for this resource"
  #checkov:skip=CKV2_AWS_61: "Lifecycle configuration not needed for dev environment"
  #checkov:skip=CKV_AWS_18: "Access logging not required for dev testing bucket"

  tags = {
    Name        = "Terraform State Storage"
    Environment = "Dev"
    ManagedBy   = "Terraform-Bootstrap"
  }
}

# Fixes CKV_AWS_21 (Enable Bucket Versioning)
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Fixes CKV_AWS_145 & CKV_AWS_19 (Enable Default KMS Encryption)
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

# Fixes CKV2_AWS_6 (Block All Public Access - Essential Security)
resource "aws_s3_bucket_public_access_block" "terraform_state_public_access" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
