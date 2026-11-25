locals {
  tags = {
    Project     = "didier-lakehouse"
    Environment = var.environment
    Owner       = "Didier"
    ManagedBy   = "Terraform"
    Application = "define two alerts for 10 USD and 20 USD"
  }

  alert_email = "torresparodisdidierjose@gmail.com"
}
