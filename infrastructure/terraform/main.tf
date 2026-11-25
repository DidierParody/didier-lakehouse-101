resource "aws_budgets_budget" "budget_alerts" {
  name         = "didier-lakehouse-${var.environment}-monthly-budget"
  budget_type  = "COST"
  limit_amount = "20"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  metrics      = ["UnblendedCost"] # required by filter_expression

  # Only costs tagged Project = didier-lakehouse AND this environment,
  # so the dev and prod budgets (same AWS account) don't count each other's spend.
  filter_expression {
    and {
      tags {
        key    = "Project"
        values = [local.tags.Project]
      }
    }
    and {
      tags {
        key    = "Environment"
        values = [var.environment]
      }
    }
  }

  # Alert 1: actual spend > 10 USD
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 10
    threshold_type             = "ABSOLUTE_VALUE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [local.alert_email]
  }

  # Alert 2: actual spend > 20 USD
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 20
    threshold_type             = "ABSOLUTE_VALUE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [local.alert_email]
  }

  tags = local.tags
}

# IAM names are account-wide and dev/prod share one account, hence the environment suffix
resource "aws_iam_role" "glue_role" {
  name               = "glue-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role.json

  tags = local.tags
}

resource "aws_iam_policy" "glue_s3_access" {
  name   = "glue-s3-access-${var.environment}"
  policy = data.aws_iam_policy_document.glue_s3_access.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "glue_service_role" {
  role       = aws_iam_role.glue_role.name
  policy_arn = data.aws_iam_policy.glue_service_role.arn
}

resource "aws_iam_role_policy_attachment" "glue_s3_access" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_s3_access.arn
}

module "s3" {
  source = "./modules/s3"

  bucket_names   = local.bucket_names
  bucket_folders = local.bucket_folders
  tags           = local.tags
}

module "glue" {
  source = "./modules/glue"

  environment      = var.environment
  role_arn         = aws_iam_role.glue_role.arn
  scripts_bucket   = module.s3.bucket_names.scripts
  lakehouse_bucket = module.s3.bucket_names.lakehouse
  tags             = local.tags
}

resource "aws_athena_workgroup" "lakehouse" {
  name          = "lakehouse-${var.environment}"
  state         = "ENABLED"
  force_destroy = true # destroy even when saved queries exist

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
    bytes_scanned_cutoff_per_query     = 1073741824 # 1 GiB per query

    result_configuration {
      output_location = "s3://${module.s3.bucket_names.lakehouse}/athena-results/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }

  tags = local.tags
}
