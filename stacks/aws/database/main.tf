# Get values from networking and compute layers
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = var.networking_state_key
    region = var.region
  }
}

data "terraform_remote_state" "compute" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = var.compute_state_key
    region = var.region
  }
}

locals {
  combined_tags = merge(var.common_tags, var.additional_tags)
}

# RDS
module "rds" {
  source = "github.com/terraform-aws-modules/terraform-aws-rds?ref=bc8c1e240a98fd54a12c61c70de91cbabec71863" # 7.2.0

  identifier = "${var.project_name}-${var.environment}-${var.region_short}-rds"

  engine               = var.engine
  engine_version       = var.engine_version
  family               = var.family
  major_engine_version = var.major_engine_version
  instance_class       = var.instance_class
  port                 = var.port

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = var.storage_encrypted

  db_name                     = var.db_name
  username                    = var.username
  manage_master_user_password = var.manage_master_user_password

  db_subnet_group_name   = data.terraform_remote_state.networking.outputs.database_subnet_group_name
  vpc_security_group_ids = [aws_security_group.db.id]

  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = true
  deletion_protection     = var.deletion_protection

  tags = local.combined_tags
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-${var.environment}-${var.region_short}-db"
  description = "Allow PostgreSQL access from EKS nodes only"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  ingress {
    description     = "PostgreSQL from EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.compute.outputs.node_security_group_id]
  }

  tags = local.combined_tags
}
