
variable "website_domain" {
  description = "The domain name of the website being hosted (without the www prefix)"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate used for SSL"
  type        = string
}
