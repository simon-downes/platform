#
# Terraform definitions for hosting simondownes.co.uk
#

terraform {
  backend "s3" {
    # these are specified in the backend.tfvars see README.md for details
    #bucket         = ""
    #dynamodb_table = ""
    #region         = ""
    key            = "simondownes.co.uk"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-west-2"
}

# ACM certificates for use with CloudFront must be created in us-east-1
provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
}

# community provider written in go that needs to be compiled and installed
# https://github.com/tiramiseb/terraform-provider-gandi
provider "gandi" {
  key = var.gandi_api_key
}

data "gandi_zone" "dns_zone" {
  name = var.website_domain
}

# ------------------------------------------------------------------------------
# First we sort the SSL certificate for the domain
# ------------------------------------------------------------------------------

# we only need to generate a certificate for the root domain as we handle
# www.domain.com -> domain.com redirects via Gandi
# we're using the aliased aws provider to create the certificate in us-east-1
resource "aws_acm_certificate" "cert" {
  provider          = aws.acm_provider
  domain_name       = var.website_domain
  validation_method = "DNS"
}

# add the validation records to Gandi
# the name of the DNS record includes the full domain so we need to strip that part
resource "gandi_zonerecord" "dns_validation" {
  zone   = data.gandi_zone.dns_zone.id
  name   = replace(aws_acm_certificate.cert.domain_validation_options.0.resource_record_name, ".${var.website_domain}.", "")
  type   = aws_acm_certificate.cert.domain_validation_options.0.resource_record_type
  ttl    = 300
  values = [aws_acm_certificate.cert.domain_validation_options.0.resource_record_value]
}

# wait for the validation to complete
resource "aws_acm_certificate_validation" "cert_validation" {
  provider        = aws.acm_provider
  certificate_arn = aws_acm_certificate.cert.arn
  depends_on = [
    gandi_zonerecord.dns_validation,
  ]
}


# ------------------------------------------------------------------------------
# Next we create the S3 buckets for hosting
# ------------------------------------------------------------------------------

# S3 bucket for static hosting
resource "aws_s3_bucket" "website" {

  bucket = var.website_domain

  acl = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  # cors_rule {
  #   allowed_headers = ["*"]
  #   allowed_methods = ["PUT","POST"]
  #   allowed_origins = ["*"]
  #   expose_headers = ["ETag"]
  #   max_age_seconds = 3000
  # }

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.website_domain}/*"
            ]
        }
    ]
}
EOF

}

# S3 bucket for www-redirect
resource "aws_s3_bucket" "website_redirect" {

  bucket = "www.${var.website_domain}"

  acl = "public-read"

  website {
    redirect_all_requests_to = var.website_domain
  }

}


# ------------------------------------------------------------------------------
# Finally we create the CloudFront distribution
# ------------------------------------------------------------------------------

# Cloudfront for caching and SSL
resource "aws_cloudfront_distribution" "cf_distro" {

  origin {
    domain_name = aws_s3_bucket.website.website_endpoint
    origin_id   = "S3-${aws_s3_bucket.website.bucket}"
    # websites hosted in an S3 bucket need to be configured as a "custom_origin" and NOT S3_Origin
    # https://stackoverflow.com/questions/40095803/how-do-you-create-an-aws-cloudfront-distribution-that-points-to-an-s3-static-ho/40096056#40096056
    custom_origin_config {
      http_port  = "80"
      https_port = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  # distribute content to US and Europe (cheapest)
  price_class = "PriceClass_100"

  aliases = ["${var.website_domain}"]

  default_cache_behavior {

    target_origin_id = "S3-${aws_s3_bucket.website.bucket}"

    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    viewer_protocol_policy = "redirect-to-https"

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    # S3 doesn't process query strings or cookies
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn      = aws_acm_certificate_validation.cert_validation.certificate_arn
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method       = "sni-only"
  }

}
