
output "s3_bucket_arn" {
  value       = aws_s3_bucket.artifact_bucket.arn
  description = "The ARN of the S3 bucket"
}
