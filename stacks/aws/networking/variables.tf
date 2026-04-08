variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "additional_tags" {
  description = "Additional tags for the networking resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "region_short" {
  description = "Short region name (e.g., eun1)"
  type        = string
}
