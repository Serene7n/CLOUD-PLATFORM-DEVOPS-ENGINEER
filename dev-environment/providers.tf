terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket  = "cloud-platform-tfstate-eu-west-1-dev"
    key     = "dev/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true

    # Enable S3 Native Locking (replaces dynamodb_table)
    use_lockfile = true
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "eu-west-1"
  profile = "Dev"
}


