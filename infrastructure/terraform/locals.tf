locals {
  tags = {
    Project     = "didier-lakehouse"
    Environment = var.environment
    Owner       = "Didier"
    ManagedBy   = "Terraform"
    Application = "define two alerts for 10 USD and 20 USD"
  }

  alert_email = "torresparodisdidierjose@gmail.com"

  bucket_names = {
    scripts   = "bucket-scripts-${random_id.bucket_suffix.hex}"
    lakehouse = "bucket-lakehouse-${random_id.bucket_suffix.hex}"
  }

  # Folder prefixes to create inside each bucket
  bucket_folders = {
    scripts   = ["glue/jobs/", "athena/queries/"]
    lakehouse = ["landing/", "bronze/", "silver/", "gold/"]
  }

  bucket_arns = { for k, name in local.bucket_names : k => "arn:aws:s3:::${name}" }
}

# S3 bucket names are global; the suffix keeps them unique (one per environment state)
resource "random_id" "bucket_suffix" {
  byte_length = 4
}
