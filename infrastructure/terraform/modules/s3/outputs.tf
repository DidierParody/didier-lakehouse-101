output "bucket_arns" {
  value = { scripts = aws_s3_bucket.scripts.arn, lakehouse = aws_s3_bucket.lakehouse.arn }
}
