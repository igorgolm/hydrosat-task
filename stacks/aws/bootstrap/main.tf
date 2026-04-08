### Terraform State Bootstrap
#### This process creates an S3 bucket and DynamoDB table for remote state storage

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  # Prevent accidental deletion of the resource
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name    = "terraform-state"
    Project = "hydrosat-taskg"
    Stack   = "bootstrap"
  }
}

# We use versioning to be able to restore previous versions of the state file
# in case of accidental deletion or corruption of the state file
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "state-history-management"
    status = "Enabled"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }

  # Checkov CKV_AWS_300
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration#abort_incomplete_multipart_upload
  rule {
    id     = "abort-incomplete-multipart-uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 2
    }
  }
}

#### Start: S3 bucket encryption
###  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration
resource "aws_kms_key" "terraform_state" {
  description             = "KMS key for Terraform state encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  rotation_period_in_days = 365

  tags = {
    Name = "terraform-state-key"
  }
}

# Enforce Server-Side Encryption (SSE) with KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_state.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}
#### End: S3 bucket encryption


#### Start: S3 bucket public access block
###  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
#### End: S3 bucket public access block

#### Start: DynamoDB state lock table
###  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table
resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST" # On-demand capacity
  hash_key     = "LockID"

  deletion_protection_enabled = true

  attribute {
    name = "LockID"
    type = "S" # String
  }

  # Encrypt the DynamoDB table with the same KMS key as the S3 bucket
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.terraform_state.arn
  }

  # Enable point-in-time recovery (PITR)
  # Checkov CKV_AWS_28
  # https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/general-6
  point_in_time_recovery {
    enabled = true
  }

  # Enable protection against accidental deletion of the resource
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name    = "terraform-state-lock"
    Project = "hydrosat-taskg"
    Stack   = "bootstrap"
  }
}
#### End: DynamoDB state lock table
