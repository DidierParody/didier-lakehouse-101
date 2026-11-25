terraform {
  # `key` is per environment: terraform init -backend-config=environments/<env>/backend.hcl
  backend "s3" {
    bucket       = "didier-lakehouse-tfstate-009377924228"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # S3-native state locking (Terraform >= 1.10), no DynamoDB table needed
  }
}
