variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "additional_tags" {
  description = "Additional tags for the resources"
  type        = map(string)
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "region_short" {
  description = "Short region name (e.g., eun1)"
  type        = string
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks that can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "terraform_state_bucket" {
  description = "Name of the S3 bucket storing terraform state"
  type        = string
  default     = "hydrosat-taskg-terraform-state"
}

variable "networking_state_key" {
  description = "Key for the networking layer's terraform state"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.35"
}

variable "eks_managed_node_groups" {
  description = "EKS managed node groups configuration"
  type        = any
}

variable "instance_types" {
  description = "List of instance types for EKS nodes"
  type        = list(string)
  default     = ["t3.small"]
}

variable "service_ipv4_cidr" {
  description = "The CIDR block to assign Kubernetes service IP addresses from. If you don't specify a block, Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks"
  type        = string
  default     = null
}
