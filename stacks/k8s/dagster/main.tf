# Get RDS password from Secrets Manager
data "aws_secretsmanager_secret_version" "rds_password" {
  secret_id = data.terraform_remote_state.database.outputs.db_instance_master_user_secret_arn
}

locals {
  db_creds      = jsondecode(data.aws_secretsmanager_secret_version.rds_password.secret_string)
  combined_tags = merge(var.common_tags, var.additional_tags)
}

# Create dagster namespace
resource "kubernetes_namespace" "dagster" {
  metadata {
    name   = "dagster"
    labels = local.combined_tags
  }
}

# Create secret for RDS password in dagster namespace with Helm labels for "ownership"
resource "kubernetes_secret" "dagster_db_secret" {
  metadata {
    name      = "dagster-rds-auth"
    namespace = kubernetes_namespace.dagster.metadata[0].name
  }

  data = {
    postgresql-password = local.db_creds.password
  }

  type = "Opaque"
}

# Create secret for Slack Webhook
resource "kubernetes_secret" "dagster_slack_webhook" {
  metadata {
    name      = "dagster-slack-webhook"
    namespace = kubernetes_namespace.dagster.metadata[0].name
  }

  data = {
    webhook-url = var.slack_webhook_url
  }

  type = "Opaque"
}

# ConfigMap for Dagster user code
resource "kubernetes_config_map" "dagster_user_code" {
  metadata {
    name      = "dagster-user-pipelines"
    namespace = "dagster"
    labels    = local.combined_tags
  }

  # Load all python files from the pipelines directory into the config map, creates a key-value pair for each file
  # where f is the key and the file content is the value
  data = {
    for f in fileset("${path.module}/pipelines", "*.py") : f => file("${path.module}/pipelines/${f}")
  }
}

# Deploy dagster via helm
# https://artifacthub.io/packages/helm/dagster/dagster
resource "helm_release" "dagster" {
  name       = "dagster"
  repository = "https://dagster-io.github.io/helm"
  chart      = "dagster"
  version    = var.dagster_version
  namespace  = kubernetes_namespace.dagster.metadata[0].name

  # Hierarchical YAML Values
  values = [
    file("${path.module}/values.yaml"), # Global defaults
    file(var.dagster_values_file)       # Env-specific overrides
  ]

  # Dynamic Overrides (from Terraform State/Secrets)
  set {
    name  = "postgresql.postgresqlHost"
    value = data.terraform_remote_state.database.outputs.db_instance_address
  }

  set {
    name  = "postgresql.postgresqlUsername"
    value = data.terraform_remote_state.database.outputs.db_instance_username
  }

  set {
    name  = "postgresql.postgresqlDatabase"
    value = data.terraform_remote_state.database.outputs.db_instance_name
  }

  set {
    name  = "postgresql.postgresqlPasswordSecret"
    value = kubernetes_secret.dagster_db_secret.metadata[0].name
  }

  depends_on = [kubernetes_secret.dagster_db_secret]
}
