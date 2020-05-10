# ACM Certificates with DNS Validation for Domains Using Gandi LiveDNS

A Terraform module for issuing ACM certificates and performing DNS validation
for domains using Gandi's LiveDNS.

The implementation is discussed in this blog post:
https://simondownes.co.uk/posts/acm-certificates-for-gandi-domains-with-terraform/

## Usage

```terraform
module "acm_gandi" {
  source      = "../modules/acm_gandi"
  cert_domain = var.cert_domain
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-------:|:--------:|
| cert_domain | The domain name to issue a certificate for | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| certificate_arn | The ARN of the created ACM certificate |
