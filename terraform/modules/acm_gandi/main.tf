
data "gandi_zone" "dns_zone" {
  name = var.cert_domain
}

resource "aws_acm_certificate" "cert" {
  domain_name       = var.cert_domain
  validation_method = "DNS"
}

resource "gandi_zonerecord" "dns_validation" {
  zone   = data.gandi_zone.dns_zone.id
  name   = replace(aws_acm_certificate.cert.domain_validation_options.0.resource_record_name, ".${var.cert_domain}.", "")
  type   = aws_acm_certificate.cert.domain_validation_options.0.resource_record_type
  ttl    = 300
  values = [aws_acm_certificate.cert.domain_validation_options.0.resource_record_value]
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn = aws_acm_certificate.cert.arn
  depends_on = [
    gandi_zonerecord.dns_validation,
  ]
}
