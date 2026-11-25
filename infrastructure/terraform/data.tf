# Trust policy: only the AWS Glue service can assume the role
data "aws_iam_policy_document" "glue_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

# AWS managed policy: Glue catalog, CloudWatch logs, etc.
data "aws_iam_policy" "glue_service_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Access to the project buckets: read job scripts, read/write the lakehouse layers
data "aws_iam_policy_document" "glue_s3_access" {
  statement {
    sid       = "ListBuckets"
    effect    = "Allow"
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = values(local.bucket_arns)
  }

  statement {
    sid       = "ReadScripts"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${local.bucket_arns.scripts}/*"]
  }

  statement {
    sid       = "ReadWriteLakehouse"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${local.bucket_arns.lakehouse}/*"]
  }
}
