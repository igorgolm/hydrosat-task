terraform {
  required_version = ">= 1.11.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # To avoid automatic updates to 7.0
    }
  }

  ## Comment for init run only!
  ## After bootstraping run: tofu -chdir=bootstrap init -migrate-state

  backend "s3" {
    key = "bootstrap/terraform.tfstate"
  }

}

provider "aws" {
  region = "eu-north-1" # Stockholm
}
