terraform {
  required_version = ">= 1.10" # backend use_lockfile

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Budgets is a global service; us-east-1 is its home region.
provider "aws" {
  region = "us-east-1"
}
