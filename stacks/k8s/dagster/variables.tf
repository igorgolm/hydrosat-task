variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "region_short" {
  description = "Short region name (e.g., eun1)"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-north-1"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "additional_tags" {
  description = "Additional tags for the environment"
  type        = map(string)
}

variable "terraform_state_bucket" {
  description = "S3 bucket for Terraform state"
  type        = string
}

variable "networking_state_key" {
  description = "S3 key for networking state"
  type        = string
}

variable "compute_state_key" {
  description = "S3 key for compute state"
  type        = string
}

variable "database_state_key" {
  description = "S3 key for database state"
  type        = string
}

variable "dagster_values_file" {
  description = "The path to the environment-specific Helm values file"
  type        = string
}

variable "dagster_version" {
  description = "The version of the Dagster Helm chart to deploy"
  type        = string
  default     = "1.12.22"
}

variable "slack_webhook_url" {
  description = "The Slack Webhook URL for alerting"
  type        = string
  default     = ""
}
