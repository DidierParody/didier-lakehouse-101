locals {
  layers = ["landing", "bronze", "silver", "gold"]
  jobs   = ["to_bronze", "to_silver", "to_gold", "load_serving"]
}

# Catalog database and crawler names are account-wide, hence the environment suffix
resource "aws_glue_catalog_database" "layer" {
  for_each = toset(local.layers)

  name = "${each.key}_${var.environment}"
  tags = var.tags
}

resource "aws_glue_crawler" "layer" {
  for_each = toset(local.layers)

  name          = "${each.key}_crawler_${var.environment}"
  role          = var.role_arn
  database_name = aws_glue_catalog_database.layer[each.key].name

  s3_target {
    path = "s3://${var.lakehouse_bucket}/${each.key}/"
  }

  tags = var.tags
}

resource "aws_glue_job" "job" {
  for_each = toset(local.jobs)

  name              = "${each.key}_${var.environment}"
  role_arn          = var.role_arn
  glue_version      = "6.0"
  worker_type       = "G.1X"
  number_of_workers = 2
  max_retries       = 2
  timeout           = 60

  command {
    script_location = "s3://${var.scripts_bucket}/glue/jobs/${each.key}.py"
    python_version  = "3"
  }

  execution_property {
    max_concurrent_runs = 1
  }

  default_arguments = {
    "--enable-metrics"                   = "true"
    "--enable-observability-metrics"     = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-job-insights"              = "true"
  }

  tags = var.tags
}
