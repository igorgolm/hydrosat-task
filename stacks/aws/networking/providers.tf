terraform {
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
