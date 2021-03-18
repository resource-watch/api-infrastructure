provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
    var.cluster_name]
    command = "aws"
  }
}

#
# Base API Gateway IAM permissions to log to cloudwatch
#
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

module "rw_api_core_api_gateway" {
  source        = "./api_gateways/core"
  dns_prefix    = var.dns_prefix
  vpc           = var.vpc
  environment   = var.environment
}

module "rw_api_gfw_api_gateway" {
  source        = "./api_gateways/gfw"
  dns_prefix    = var.dns_prefix
  vpc           = var.vpc
  environment   = var.environment
}

module "rw_api_misc_api_gateway" {
  source        = "./api_gateways/misc"
  dns_prefix    = var.dns_prefix
  vpc           = var.vpc
  environment   = var.environment
}

#
# DNS Management
#
data "cloudflare_zones" "resourcewatch" {
  filter {
    name   = "resourcewatch.org"
    status = "active"
    paused = false
  }
}

//// aws-{env}.resourcewatch.org
//resource "aws_acm_certificate" "aws_env_resourcewatch_org_domain_cert" {
//  domain_name       = "aws-${var.dns_prefix}.${data.cloudflare_zones.resourcewatch.zones[0].name}"
//  validation_method = "DNS"
//
//  lifecycle {
//    create_before_destroy = true
//  }
//}
//
//resource "cloudflare_record" "aws_env_resourcewatch_org_dns_validation" {
//  zone_id = data.cloudflare_zones.resourcewatch.zones[0].id
//  name    = tolist(aws_acm_certificate.aws_env_resourcewatch_org_domain_cert.domain_validation_options)[0].resource_record_name
//  value   = trim(tolist(aws_acm_certificate.aws_env_resourcewatch_org_domain_cert.domain_validation_options)[0].resource_record_value, ".")
//  type    = "CNAME"
//  ttl     = 120
//}
//
//resource "cloudflare_record" "aws_env_resourcewatch_org_dns" {
//  zone_id = data.cloudflare_zones.resourcewatch.zones[0].id
//  name    = "aws-${var.dns_prefix}.${data.cloudflare_zones.resourcewatch.zones[0].name}"
//  value   = aws_api_gateway_domain_name.aws_env_resourcewatch_org_gateway_domain_name.cloudfront_domain_name
//  type    = "CNAME"
//  ttl     = 120
//}
//
//resource "aws_acm_certificate_validation" "aws_env_resourcewatch_org_domain_cert_validation" {
//  certificate_arn = aws_acm_certificate.aws_env_resourcewatch_org_domain_cert.arn
//
//  depends_on = [
//    cloudflare_record.aws_env_resourcewatch_org_dns_validation,
//  ]
//}
//
//resource "aws_api_gateway_domain_name" "aws_env_resourcewatch_org_gateway_domain_name" {
//  certificate_arn = aws_acm_certificate_validation.aws_env_resourcewatch_org_domain_cert_validation.certificate_arn
//  domain_name     = "aws-${var.dns_prefix}.${data.cloudflare_zones.resourcewatch.zones[0].name}"
//
//  depends_on = [
//  aws_acm_certificate_validation.aws_env_resourcewatch_org_domain_cert_validation]
//}
//
//resource "aws_api_gateway_base_path_mapping" "aws_env_resourcewatch_org_base_path_mapping" {
//  api_id      = module.rw_api_core_api_gateway.aws_api_gateway_rest_api.id
//  stage_name  = module.rw_api_v1_api_gateway.aws_api_gateway_deployment.stage_name
//  domain_name = aws_api_gateway_domain_name.aws_env_resourcewatch_org_gateway_domain_name.domain_name
//}
//
//// {env}-api.resourcewatch.org
//resource "aws_acm_certificate" "env_api_resourcewatch_org_domain_cert" {
//  domain_name       = "${var.dns_prefix}-api.${data.cloudflare_zones.resourcewatch.zones[0].name}"
//  validation_method = "DNS"
//
//  lifecycle {
//    create_before_destroy = true
//  }
//}
//
//resource "cloudflare_record" "env_api_resourcewatch_org_dns_validation" {
//  zone_id = data.cloudflare_zones.resourcewatch.zones[0].id
//  name    = tolist(aws_acm_certificate.env_api_resourcewatch_org_domain_cert.domain_validation_options)[0].resource_record_name
//  value   = trim(tolist(aws_acm_certificate.env_api_resourcewatch_org_domain_cert.domain_validation_options)[0].resource_record_value, ".")
//  type    = "CNAME"
//  ttl     = 120
//}
//
//resource "cloudflare_record" "env_api_resourcewatch_org_dns" {
//  zone_id = data.cloudflare_zones.resourcewatch.zones[0].id
//  name    = "${var.dns_prefix}-api.${data.cloudflare_zones.resourcewatch.zones[0].name}"
//  value   = aws_api_gateway_domain_name.env_api_resourcewatch_org_gateway_domain_name.cloudfront_domain_name
//  type    = "CNAME"
//  ttl     = 120
//}
//
//resource "aws_acm_certificate_validation" "env_api_resourcewatch_org_domain_cert_validation" {
//  certificate_arn = aws_acm_certificate.env_api_resourcewatch_org_domain_cert.arn
//
//  depends_on = [
//    cloudflare_record.env_api_resourcewatch_org_dns_validation,
//  ]
//}
//
//resource "aws_api_gateway_domain_name" "env_api_resourcewatch_org_gateway_domain_name" {
//  certificate_arn = aws_acm_certificate_validation.env_api_resourcewatch_org_domain_cert_validation.certificate_arn
//  domain_name     = "${var.dns_prefix}-api.${data.cloudflare_zones.resourcewatch.zones[0].name}"
//
//  depends_on = [
//  aws_acm_certificate_validation.env_api_resourcewatch_org_domain_cert_validation]
//}
//
//resource "aws_api_gateway_base_path_mapping" "env_api_resourcewatch_org_base_path_mapping" {
//  api_id      = module.rw_api_core_api_gateway.aws_api_gateway_rest_api.id
//  stage_name  = module.rw_api_v1_api_gateway.aws_api_gateway_deployment.stage_name
//  domain_name = aws_api_gateway_domain_name.env_api_resourcewatch_org_gateway_domain_name.domain_name
//}
//
//// TODO: if we don't move the globalforestwatch.org DNS into TF, this will have to stay a manual thing
//// {env}-api.globalforestwatch.org
//resource "aws_acm_certificate" "env_api_globalforestwatch_org_domain_cert" {
//  domain_name       = "${var.dns_prefix}-api.globalforestwatch.org"
//  validation_method = "DNS"
//
//  lifecycle {
//    create_before_destroy = true
//  }
//}

//resource "aws_acm_certificate_validation" "env_api_globalforestwatch_org_domain_cert_validation" {
//  certificate_arn = aws_acm_certificate.env_api_globalforestwatch_org_domain_cert.arn
//}
//
//resource "aws_api_gateway_domain_name" "env_api_globalforestwatch_org_gateway_domain_name" {
//  certificate_arn = aws_acm_certificate_validation.env_api_globalforestwatch_org_domain_cert_validation.certificate_arn
//  domain_name     = "${var.dns_prefix}-api.globalforestwatch.org"
//
//  depends_on = [
//    aws_acm_certificate_validation.env_api_globalforestwatch_org_domain_cert_validation]
//}
//
//resource "aws_api_gateway_base_path_mapping" "env_api_globalforestwatch_org_base_path_mapping" {
//  api_id      = module.rw_api_core_api_gateway.aws_api_gateway_rest_api.id
//  stage_name  = aws_api_gateway_deployment.prod.stage_name
//  domain_name = aws_api_gateway_domain_name.env_api_globalforestwatch_org_gateway_domain_name.domain_name
//}