resource "aws_api_gateway_account" "api_gateway_monitoring_account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_monitoring.arn
}

resource "aws_iam_role" "api_gateway_monitoring" {
  name = "api_gateway_cloudwatch_global"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "api_gateway_monitoring_cloudwatch_policy" {
  name = "default"
  role = aws_iam_role.api_gateway_monitoring.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_api_gateway_method_settings" "rw_api_gateway_general_settings" {
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  stage_name  = aws_api_gateway_deployment.prod.stage_name
  method_path = "*/*"

  settings {
    # Enable CloudWatch logging and metrics
    metrics_enabled        = true
    data_trace_enabled     = true
    logging_level          = "INFO"

    # Limit the rate of calls to prevent abuse and unwanted charges
    throttling_rate_limit  = 100
    throttling_burst_limit = 50
  }
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
      jsonencode(module.dataset.endpoints),
      jsonencode(module.widget.endpoints),
      jsonencode(module.ct.endpoints),
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

resource "aws_api_gateway_resource" "v2_resource" {
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.rw_api_gateway.root_resource_id
  path_part   = "v2"
}

resource "aws_api_gateway_resource" "v3_resource" {
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.rw_api_gateway.root_resource_id
  path_part   = "v3"
}

module "dataset" {
  source           = "./dataset"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  resource_root    = aws_api_gateway_resource.v1_resource
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
}

module "widget" {
  source           = "./widget"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  resource_root    = aws_api_gateway_resource.v1_resource
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
}

module "ct" {
  source           = "./ct"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  v1_resource_root    = aws_api_gateway_resource.v1_resource
  v2_resource_root    = aws_api_gateway_resource.v2_resource
  v3_resource_root    = aws_api_gateway_resource.v3_resource
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
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
  name    = tolist(aws_acm_certificate.api_domain_cert.domain_validation_options)[0].resource_record_name
  value   = trim(tolist(aws_acm_certificate.api_domain_cert.domain_validation_options)[0].resource_record_value, ".")
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
