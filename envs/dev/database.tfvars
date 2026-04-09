instance_class         = "db.t3.micro"
project_name           = "hydrosat-taskg"
environment            = "dev"
region_short           = "eun1"
networking_state_key   = "envs/dev/networking/terraform.tfstate"
compute_state_key      = "envs/dev/compute/terraform.tfstate"
terraform_state_bucket = "hydrosat-taskg-dev-terraform-state"

additional_tags = {
  Stack = "database"
}

backup_retention_period = 0 # For Free Tier

engine               = "postgres"
engine_version       = "17"
family               = "postgres17"
major_engine_version = "17"
port                 = 5432

allocated_storage     = 20
max_allocated_storage = 100
storage_encrypted     = true

db_name                     = "taskg"
username                    = "taskg"
manage_master_user_password = true
