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

module "acm_gandi" {

  source = "../modules/acm_gandi"

  # specify providers explicitly as we want the module to use the acm_provider
  providers = {
    aws   = aws.acm_provider
    gandi = gandi
  }

  # we only need to generate a certificate for the root domain as we handle
  # www.domain.com -> domain.com redirects via Gandi manually
  cert_domain = var.website_domain

}

module "s3_hosting" {

  source = "../modules/s3_hosting"

  providers = {
    aws = aws
  }

  website_domain  = var.website_domain
  certificate_arn = module.acm_gandi.cert_arn

}
