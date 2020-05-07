
output "website_bucket_arn" {
  value       = aws_s3_bucket.website.arn
  description = "The ARN of the hosting S3 bucket"
}

output "redirect_bucket_arn" {
  value       = aws_s3_bucket.website_redirect.arn
  description = "The ARN of the www redirect S3 bucket"
}

output "s3_endpoint" {
  value       = aws_s3_bucket.website.website_endpoint
  description = "S3 endpoint for the hosted website"
}

output "cf_endpoint" {
  value       = aws_cloudfront_distribution.cf_distro.domain_name
  description = "CloudFront domain of the website"
}
