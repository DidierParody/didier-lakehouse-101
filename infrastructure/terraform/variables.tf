variable "environment" {
  description = "Deployment environment: dev (branch dev) or prod (branch main)"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be \"dev\" or \"prod\"."
  }
}
