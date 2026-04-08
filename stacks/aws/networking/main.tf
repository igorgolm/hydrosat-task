# Data sources for getting available AZs and using it in VPC module with slicing
data "aws_availability_zones" "available" {
  state = "available"
}

# Merge common and additional tags
locals {
  combined_tags = merge(var.common_tags, var.additional_tags)
}

# VPC
module "vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc?ref=3ffbd46fb1c7733e1b34d8666893280454e27436" # 6.6.1

  name = "${var.project_name}-${var.environment}-vpc"
  cidr = var.vpc_cidr
  # Use first 2 AZs for networking
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  private_subnets  = [for k, _ in slice(data.aws_availability_zones.available.names, 0, 2) : cidrsubnet(var.vpc_cidr, 8, k)]
  public_subnets   = [for k, _ in slice(data.aws_availability_zones.available.names, 0, 2) : cidrsubnet(var.vpc_cidr, 8, k + 4)]
  database_subnets = [for k, _ in slice(data.aws_availability_zones.available.names, 0, 2) : cidrsubnet(var.vpc_cidr, 8, k + 8)]

  enable_nat_gateway   = true # Enable NAT gateway for private subnets
  single_nat_gateway   = true # Use a single NAT gateway for cost savings
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Create database subnet group for RDS
  create_database_subnet_group = true

  # Tags for EKS identification (standard for modern VPC modules)
  public_subnet_tags = {
    "kubernetes.io/role/elb"                                                               = 1
    "kubernetes.io/cluster/${var.project_name}-${var.environment}-${var.region_short}-eks" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"                                                      = 1
    "kubernetes.io/cluster/${var.project_name}-${var.environment}-${var.region_short}-eks" = "shared"
  }

  tags = local.combined_tags
}
