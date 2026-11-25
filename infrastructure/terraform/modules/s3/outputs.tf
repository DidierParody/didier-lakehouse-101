output "bucket_arns" {
  value = { scripts = aws_s3_bucket.scripts.arn, lakehouse = aws_s3_bucket.lakehouse.arn }
}

output "bucket_names" {
  value = { scripts = aws_s3_bucket.scripts.bucket, lakehouse = aws_s3_bucket.lakehouse.bucket }
}
