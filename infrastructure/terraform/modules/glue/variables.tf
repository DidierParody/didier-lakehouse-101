variable "environment" {
  description = "dev or prod"
  type        = string
}

variable "role_arn" {
  description = "IAM role used by the crawlers and jobs"
  type        = string
}

variable "scripts_bucket" {
  description = "Bucket holding job scripts under glue/jobs/"
  type        = string
}

variable "lakehouse_bucket" {
  description = "Bucket holding the landing/bronze/silver/gold layers"
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource"
  type        = map(string)
}
