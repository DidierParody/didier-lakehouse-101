resource "aws_s3_bucket" "scripts" {
  bucket = var.bucket_names.scripts
  tags   = var.tags
}

resource "aws_s3_bucket" "lakehouse" {
  bucket = var.bucket_names.lakehouse
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "scripts" {
  bucket = aws_s3_bucket.scripts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "lakehouse" {
  bucket = aws_s3_bucket.lakehouse.id
  versioning_configuration {
    status = "Enabled"
  }
}

# One empty "folder/" object per prefix, keyed "<bucket>/<prefix>"
resource "aws_s3_object" "folders" {
  for_each = merge([
    for b, prefixes in var.bucket_folders : { for p in prefixes : "${b}/${p}" => { bucket = b, key = p } }
  ]...)

  bucket  = each.value.bucket == "scripts" ? aws_s3_bucket.scripts.id : aws_s3_bucket.lakehouse.id
  key     = each.value.key
  content = ""
  tags    = var.tags
}

resource "aws_s3_bucket_lifecycle_configuration" "scripts" {
  bucket     = aws_s3_bucket.scripts.id
  depends_on = [aws_s3_bucket_versioning.scripts] # noncurrent rules need versioning on first

  rule {
    id     = "basic"
    status = "Enabled"
    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lakehouse" {
  bucket     = aws_s3_bucket.lakehouse.id
  depends_on = [aws_s3_bucket_versioning.lakehouse]

  rule {
    id     = "expire-old-versions"
    status = "Enabled"
    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  # Athena writes a result file per query and never cleans up
  rule {
    id     = "expire-athena-results"
    status = "Enabled"

    filter {
      prefix = "athena-results/"
    }

    expiration {
      days = 7
    }
  }

  dynamic "rule" {
    for_each = {
      landing = { days = 30, storage_class = "GLACIER" }
      bronze  = { days = 90, storage_class = "STANDARD_IA" }
      silver  = { days = 60, storage_class = "STANDARD_IA" }
      gold    = { days = 90, storage_class = "STANDARD_IA" }
    }

    content {
      id     = rule.key
      status = "Enabled"

      filter {
        prefix = "${rule.key}/"
      }

      transition {
        days          = rule.value.days
        storage_class = rule.value.storage_class
      }
    }
  }
}
