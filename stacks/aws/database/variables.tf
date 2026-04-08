variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "additional_tags" {
  description = "Additional tags for the environment"
  type        = map(string)
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "region_short" {
  description = "Short region name (e.g., eun1)"
  type        = string
}

variable "instance_class" {
  description = "The instance class for the RDS database"
  type        = string
}

variable "terraform_state_bucket" {
  description = "Name of the S3 bucket storing terraform state"
  type        = string
}

variable "networking_state_key" {
  description = "Key for the networking layer's terraform state"
  type        = string
}

variable "compute_state_key" {
  description = "Key for the compute layer's terraform state"
  type        = string
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  type        = number
  default     = 7
}

variable "engine" {
  description = "The database engine to use"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "The engine version to use"
  type        = string
  default     = "17"
}

variable "family" {
  description = "The family of the DB parameter group"
  type        = string
  default     = "postgres17"
}

variable "major_engine_version" {
  description = "The major engine version"
  type        = string
  default     = "17"
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = number
  default     = 5432
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "The upper limit to which RDS can automatically scale the storage"
  type        = number
  default     = 100
}

variable "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted"
  type        = bool
  default     = true
}

variable "db_name" {
  description = "The name of the database to create when the DB instance is created"
  type        = string
  default     = "taskg"
}

variable "username" {
  description = "Username for the master DB user"
  type        = string
  default     = "admin"
}

variable "manage_master_user_password" {
  description = "Whether to manage the master user password with AWS Secrets Manager"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection for the DB instance"
  type        = bool
  default     = false
}
