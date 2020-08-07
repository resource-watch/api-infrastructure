# Cloudflare provider, so we can manage DNS
provider "cloudflare" {
  version = "~> 2.0"
}

resource "aws_api_gateway_rest_api" "rw_api_gateway" {
  name        = "rw-api-${replace(var.environment, " ", "-")}"
  description = "API Gateway for the RW API ${var.environment} cluster"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "prod" {
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  stage_name  = "prod"

  triggers = {
    redeployment = sha1(join(",", list(
      jsonencode(module.dataset.dateset_endpoints),
    )))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.rw_api_gateway.root_resource_id
  path_part   = "v1"
}

module "dataset" {
  source        = "./dataset"
  api_gateway   = aws_api_gateway_rest_api.rw_api_gateway
  resource_root = aws_api_gateway_resource.v1_resource
}

# DNS Management
data "cloudflare_zones" "resourcewatch" {
  filter {
    name   = "resourcewatch.org"
    status = "active"
    paused = false
  }
}

resource "aws_acm_certificate" "api_domain_cert" {
  domain_name       = "${var.dns_prefix}.${data.cloudflare_zones.resourcewatch.zones[0].name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_record" "api_dns_validation" {
  zone_id = data.cloudflare_zones.resourcewatch.zones[0].id
  name    = aws_acm_certificate.api_domain_cert.domain_validation_options.0.resource_record_name
  value   = trim(aws_acm_certificate.api_domain_cert.domain_validation_options.0.resource_record_value, ".")
  type    = "CNAME"
  ttl     = 120
}

resource "cloudflare_record" "api_dns" {
  zone_id = data.cloudflare_zones.resourcewatch.zones[0].id
  name    = "${var.dns_prefix}.${data.cloudflare_zones.resourcewatch.zones[0].name}"
  value   = aws_api_gateway_domain_name.api_gateway_domain_name.cloudfront_domain_name
  type    = "CNAME"
  ttl     = 120
}

resource "aws_acm_certificate_validation" "api_domain_cert_validation" {
  certificate_arn = aws_acm_certificate.api_domain_cert.arn

  depends_on = [
    cloudflare_record.api_dns_validation,
  ]
}

resource "aws_api_gateway_domain_name" "api_gateway_domain_name" {
  certificate_arn = aws_acm_certificate_validation.api_domain_cert_validation.certificate_arn
  domain_name     = "${var.dns_prefix}.${data.cloudflare_zones.resourcewatch.zones[0].name}"

  depends_on = [aws_acm_certificate_validation.api_domain_cert_validation]
}

resource "aws_api_gateway_base_path_mapping" "aws_api_gateway_base_path_mapping" {
  api_id      = aws_api_gateway_rest_api.rw_api_gateway.id
  stage_name  = aws_api_gateway_deployment.prod.stage_name
  domain_name = aws_api_gateway_domain_name.api_gateway_domain_name.domain_name
}
