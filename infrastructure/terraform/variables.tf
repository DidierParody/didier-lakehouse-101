variable "environment" {
  description = "Deployment environment: dev (branch dev) or prod (branch main)"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be \"dev\" or \"prod\"."
  }
}

# Set only in CI apply, from the GitHub environment secret NEON_DB_CREDENTIALS (JSON).
# Ephemeral + write-only: the value is never stored in plan or state.
variable "neon_db_credentials" {
  description = "Neon credentials JSON: {\"host\",\"port\",\"dbname\",\"username\",\"password\"}"
  type        = string
  default     = null # PR plans run without it
  sensitive   = true
  ephemeral   = true

  validation {
    condition     = var.neon_db_credentials == null || can(jsondecode(var.neon_db_credentials))
    error_message = "neon_db_credentials must be valid JSON (is the NEON_DB_CREDENTIALS secret set?)."
  }
}
