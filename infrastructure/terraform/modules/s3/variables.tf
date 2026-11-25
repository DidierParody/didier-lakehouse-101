variable "bucket_names" {
  description = "Bucket names keyed by role: scripts, lakehouse"
  type        = object({ scripts = string, lakehouse = string })
}

variable "bucket_folders" {
  description = "Folder prefixes to create, keyed by bucket role"
  type        = map(list(string))
}

variable "tags" {
  description = "Tags applied to every resource"
  type        = map(string)
}
