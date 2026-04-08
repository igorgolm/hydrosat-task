bucket         = "hydrosat-taskg-terraform-state"
region         = "eu-north-1"
dynamodb_table = "hydrosat-taskg-terraform-locks"
encrypt        = true
kms_key_id     = "arn:aws:kms:eu-north-1:719429929506:key/66898d71-99bc-4c78-b318-af6863e93c53" # Get it after bootstrap
