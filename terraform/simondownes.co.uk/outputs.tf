
output "cf_endpoint" {
  value       = module.s3_hosting.cf_endpoint
  description = "CloudFront domain of the website"
}

output "s3_endpoint" {
  value       = module.s3_hosting.s3_endpoint
  description = "S3 endpoint for the hosted website"
}
