bucket         = "hydrosat-taskg-dev-terraform-state"
region         = "eu-north-1"
dynamodb_table = "hydrosat-taskg-dev-terraform-locks"
encrypt        = true
kms_key_id     = "arn:aws:kms:eu-north-1:719429929506:key/6b5f2c67-d0ad-42e7-bbb4-061d1132abcd" # Managed by dev-bootstrap stack
