output "cert_arn" {
  description = "The ARN of the created ACM certificate"
  value       = aws_acm_certificate_validation.cert_validation.certificate_arn
}
