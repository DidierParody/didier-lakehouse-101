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
