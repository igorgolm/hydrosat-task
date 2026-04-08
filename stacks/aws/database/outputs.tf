output "db_instance_address" {
  description = "The connection endpoint for the RDS instance (hostname)"
  value       = module.rds.db_instance_address
}

output "db_instance_name" {
  description = "The database name"
  value       = module.rds.db_instance_name
}

output "db_instance_username" {
  description = "The database user"
  value       = module.rds.db_instance_username
  sensitive   = true
}

output "db_instance_port" {
  description = "The database port"
  value       = module.rds.db_instance_port
}

output "db_instance_master_user_secret_arn" {
  description = "The ARN of the master user secret"
  value       = module.rds.db_instance_master_user_secret_arn
  sensitive   = true
}
