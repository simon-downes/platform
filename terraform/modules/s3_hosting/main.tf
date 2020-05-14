# ------------------------------------------------------------------------------
# Terraform module for setting up static website hosting with S3 and CloudFront
# ------------------------------------------------------------------------------

locals {
  website_bucket  = var.website_domain
  redirect_bucket = "www.${var.website_domain}"
  cf_origin_id    = "S3-${var.website_domain}"
}

# ------------------------------------------------------------------------------
# First we create the S3 buckets for hosting
# ------------------------------------------------------------------------------

# S3 bucket for static hosting
resource "aws_s3_bucket" "website" {

  bucket = local.website_bucket

  acl = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  # delete the content of the bucket when running terraform destroy
  force_destroy = true

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
                "arn:aws:s3:::${local.website_bucket}/*"
            ]
        }
    ]
}
EOF

}

# S3 bucket for www-redirect
resource "aws_s3_bucket" "website_redirect" {

  bucket = local.redirect_bucket

  acl = "public-read"

  website {
    redirect_all_requests_to = var.website_domain
  }

}


# ------------------------------------------------------------------------------
# Next we create the CloudFront distribution
# ------------------------------------------------------------------------------

resource "aws_cloudfront_distribution" "cf_distro" {

  origin {
    domain_name = aws_s3_bucket.website.website_endpoint
    origin_id   = local.cf_origin_id
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

    target_origin_id = local.cf_origin_id

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
    acm_certificate_arn      = var.certificate_arn
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method       = "sni-only"
  }

}
