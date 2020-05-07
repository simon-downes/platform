
# the domain name of the website being hosted (without the www prefix)
variable "website_domain" {
  type = string
  default = "simondownes.co.uk"
}

# api key used to access Gandi
# this should be set via the TF_VAR_gandi_api_key environment variable
variable "gandi_api_key" {
  type = string
}
