project_name           = "hydrosat-taskg"
environment            = "dev"
terraform_state_bucket = "hydrosat-taskg-dev-terraform-state"
networking_state_key   = "envs/dev/networking/terraform.tfstate"
compute_state_key      = "envs/dev/compute/terraform.tfstate"
database_state_key     = "envs/dev/database/terraform.tfstate"

dagster_values_file = "../../../envs/dev/dagster-values.yaml"

additional_tags = {
  Environment = "dev"
  Stack       = "dagster"
}

slack_webhook_url = "https://example.com/slack/webhook"
