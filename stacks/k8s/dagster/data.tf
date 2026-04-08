data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = var.networking_state_key
    region = "eu-north-1"
  }
}

data "terraform_remote_state" "compute" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = var.compute_state_key
    region = "eu-north-1"
  }
}

data "terraform_remote_state" "database" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = var.database_state_key
    region = "eu-north-1"
  }
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.compute.outputs.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.compute.outputs.cluster_name
}
