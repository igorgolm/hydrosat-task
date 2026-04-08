terraform {
  required_version = ">= 1.11.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.39.0"
    }
  }

  backend "s3" {
    # Partial configuration retrieved from common_backend.hcl during init
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.common_tags
  }
}
