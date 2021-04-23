# import core state
data "terraform_remote_state" "core" {
  backend = "s3"
  config = {
    bucket = var.tf_core_state_bucket
    region = var.aws_region
    key    = "core.tfstate"
  }
}

provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

#
# Base API Gateway setup
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

resource "aws_api_gateway_method_settings" "rw_api_gateway_general_settings" {
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  stage_name  = aws_api_gateway_deployment.prod.stage_name
  method_path = "*/*"

  settings {
    # Enable CloudWatch logging and metrics
    metrics_enabled    = true
    data_trace_enabled = true
    logging_level      = "INFO"

    # Limit the rate of calls to prevent abuse and unwanted charges
    throttling_rate_limit  = 100
    throttling_burst_limit = 50
  }
}

resource "aws_api_gateway_rest_api" "rw_api_gateway" {
  name        = "rw-api-${replace(var.dns_prefix, " ", "-")}"
  description = "API Gateway for the RW API ${var.dns_prefix} cluster"

  endpoint_configuration {
    types = [
    "REGIONAL"]
  }
}

data "aws_subnet_ids" "private_subnets" {
  vpc_id = var.vpc.id

  tags = {
    tier = "private"
  }
}

data "aws_subnet_ids" "public_subnets" {
  vpc_id = var.vpc.id

  tags = {
    tier = "public"
  }
}

data "aws_autoscaling_groups" "apps_autoscaling_group" {
  filter {
    name   = "key"
    values = ["eks:nodegroup-name"]
  }

  filter {
    name   = "value"
    values = [data.terraform_remote_state.core.outputs.node_group_names["apps"]]
  }
}

data "aws_autoscaling_groups" "core_autoscaling_group" {
  filter {
    name   = "key"
    values = ["eks:nodegroup-name"]
  }

  filter {
    name   = "value"
    values = [data.terraform_remote_state.core.outputs.node_group_names["core"]]
  }
}

data "aws_autoscaling_groups" "gfw_autoscaling_group" {
  filter {
    name   = "key"
    values = ["eks:nodegroup-name"]
  }
  filter {
    name   = "value"
    values = [data.terraform_remote_state.core.outputs.node_group_names["gfw"]]
  }
}

resource "aws_lb" "api_gateway_apps_nlb" {
  name               = "rw-api-apps-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = data.aws_subnet_ids.public_subnets.ids

  enable_deletion_protection = true
}

resource "aws_api_gateway_vpc_link" "rw_api_apps_lb_vpc_link" {
  name        = "RW API apps LB VPC link"
  description = "VPC link to the RW API service apps load balancer"
  target_arns = [aws_lb.api_gateway_apps_nlb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "api_gateway_core_nlb" {
  name               = "rw-api-core-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = data.aws_subnet_ids.public_subnets.ids

  enable_deletion_protection = true
}

resource "aws_api_gateway_vpc_link" "rw_api_core_lb_vpc_link" {
  name        = "RW API core LB VPC link"
  description = "VPC link to the RW API service core load balancer"
  target_arns = [aws_lb.api_gateway_core_nlb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "api_gateway_gfw_nlb" {
  name               = "rw-api-gfw-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = data.aws_subnet_ids.public_subnets.ids

  enable_deletion_protection = true
}

resource "aws_api_gateway_vpc_link" "rw_api_gfw_lb_vpc_link" {
  name        = "RW API gfw LB VPC link"
  description = "VPC link to the RW API service GFW load balancer"
  target_arns = [aws_lb.api_gateway_gfw_nlb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_deployment" "prod" {
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  stage_name  = "prod"

  triggers = {
    redeployment = sha1(join(",", list(
      jsonencode(aws_api_gateway_integration.get_v1_endpoint_integration),
      jsonencode(module.gfw_metadata.endpoints),
      //    jsonencode(module.doc_swagger.endpoints),
      jsonencode(module.auth.endpoints),
      jsonencode(module.ct.endpoints),
      //    jsonencode(module.dataset.endpoints),
      //    jsonencode(module.layer.endpoints),
      //    jsonencode(module.query.endpoints),
      //    jsonencode(module.query.endpoints),
      jsonencode(module.resource-watch-manager.endpoints),
      //    jsonencode(module.widget.endpoints),
      //    jsonencode(module.metadata.endpoints),
      //    jsonencode(module.webshot.endpoints),
    )))
  }

  lifecycle {
    create_before_destroy = true
  }
}

#
# Endpoint creation
#

// Base API Gateway resources
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


// /v1 200 response, needed by FW
resource "aws_api_gateway_method" "get_v1_endpoint_method" {
  rest_api_id   = aws_api_gateway_rest_api.rw_api_gateway.id
  resource_id   = aws_api_gateway_resource.v1_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_v1_endpoint_integration" {
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  resource_id = aws_api_gateway_resource.v1_resource.id
  http_method = aws_api_gateway_method.get_v1_endpoint_method.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" : "{\"statusCode\": 200}"
  }
  depends_on = [
  aws_api_gateway_method.get_v1_endpoint_method]
}

resource "aws_api_gateway_method_response" "get_v1_endpoint_method_response" {
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  resource_id = aws_api_gateway_resource.v1_resource.id
  http_method = aws_api_gateway_method.get_v1_endpoint_method.http_method
  status_code = 200
}

resource "aws_api_gateway_integration_response" "get_v1_endpoint_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  resource_id = aws_api_gateway_resource.v1_resource.id
  http_method = aws_api_gateway_method.get_v1_endpoint_method.http_method
  status_code = aws_api_gateway_method_response.get_v1_endpoint_method_response.status_code

  # Transforms the backend JSON response to XML
  response_templates = {
    "application/json" = <<EOF
#set($inputRoot = $input.path('$'))
{ }
EOF
  }
}


// Nginx reverse proxy config, remapped

// /v1/gfw-metadata proxies to external server
module "gfw_metadata" {
  source           = "./gfw-metadata"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  resource_root_id = aws_api_gateway_rest_api.rw_api_gateway.root_resource_id
}

// /documentation uses doc-swagger MS (no CT)
//module "doc_swagger" {
//  source           = "./doc-swagger"
//  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
//  resource_root_id = aws_api_gateway_rest_api.rw_api_gateway.root_resource_id
//  cluster_ca       = var.cluster_ca
//  cluster_endpoint = var.cluster_endpoint
//  cluster_name     = var.cluster_name
//}


// Import routes per MS, one by one
module "ct" {
  source           = "./ct"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  resource_root_id = aws_api_gateway_rest_api.rw_api_gateway.root_resource_id
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
}

module "auth" {
  source           = "./authorization"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_core_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_core_lb_vpc_link
  root_resource_id = aws_api_gateway_rest_api.rw_api_gateway.root_resource_id

  eks_asg_names = [
    data.aws_autoscaling_groups.core_autoscaling_group.names.0
  ]
}

//module "dataset" {
//  source           = "./dataset"
//  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
//  resource_root_id = aws_api_gateway_resource.v1_resource.id
//  cluster_ca       = var.cluster_ca
//  cluster_endpoint = var.cluster_endpoint
//  cluster_name     = var.cluster_name
//}
//
//module "widget" {
//  source           = "./widget"
//  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
//  resource_root_id = aws_api_gateway_resource.v1_resource.id
//  cluster_ca       = var.cluster_ca
//  cluster_endpoint = var.cluster_endpoint
//  cluster_name     = var.cluster_name
//}
//
//module "layer" {
//  source           = "./layer"
//  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
//  resource_root_id = aws_api_gateway_resource.v1_resource.id
//  cluster_ca       = var.cluster_ca
//  cluster_endpoint = var.cluster_endpoint
//  cluster_name     = var.cluster_name
//}
//
//module "metadata" {
//  source           = "./metadata"
//  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
//  resource_root_id = aws_api_gateway_resource.v1_resource.id
//  cluster_ca       = var.cluster_ca
//  cluster_endpoint = var.cluster_endpoint
//  cluster_name     = var.cluster_name
//}
//
//module "query" {
//  source           = "./query"
//  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
//  resource_root_id = aws_api_gateway_resource.v1_resource.id
//  cluster_ca       = var.cluster_ca
//  cluster_endpoint = var.cluster_endpoint
//  cluster_name     = var.cluster_name
//}

module "resource-watch-manager" {
  source           = "./resource-watch-manager"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_apps_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = aws_api_gateway_resource.v1_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0
  ]
}

//module "webshot" {
//  source           = "./webshot"
//  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
//  resource_root_id = aws_api_gateway_resource.v1_resource.id
//  cluster_ca       = var.cluster_ca
//  cluster_endpoint = var.cluster_endpoint
//  cluster_name     = var.cluster_name
//}
//
//module "viirs_fires" {
//  source              = "./viirs-fires"
//  api_gateway         = aws_api_gateway_rest_api.rw_api_gateway
//  resource_root_v1_id = aws_api_gateway_resource.v1_resource.id
//  resource_root_v2_id = aws_api_gateway_resource.v2_resource.id
//  cluster_ca          = var.cluster_ca
//  cluster_endpoint    = var.cluster_endpoint
//  cluster_name        = var.cluster_name
//}

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

// aws-{env}.resourcewatch.org
resource "aws_acm_certificate" "aws_env_resourcewatch_org_domain_cert" {
  domain_name       = "aws-${var.dns_prefix}.${data.cloudflare_zones.resourcewatch.zones[0].name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_record" "aws_env_resourcewatch_org_dns_validation" {
  zone_id = data.cloudflare_zones.resourcewatch.zones[0].id
  name    = tolist(aws_acm_certificate.aws_env_resourcewatch_org_domain_cert.domain_validation_options)[0].resource_record_name
  value   = trim(tolist(aws_acm_certificate.aws_env_resourcewatch_org_domain_cert.domain_validation_options)[0].resource_record_value, ".")
  type    = "CNAME"
  ttl     = 120
}

resource "cloudflare_record" "aws_env_resourcewatch_org_dns" {
  zone_id = data.cloudflare_zones.resourcewatch.zones[0].id
  name    = "aws-${var.dns_prefix}.${data.cloudflare_zones.resourcewatch.zones[0].name}"
  value   = aws_api_gateway_domain_name.aws_env_resourcewatch_org_gateway_domain_name.cloudfront_domain_name
  type    = "CNAME"
  ttl     = 120
}

resource "aws_acm_certificate_validation" "aws_env_resourcewatch_org_domain_cert_validation" {
  certificate_arn = aws_acm_certificate.aws_env_resourcewatch_org_domain_cert.arn

  depends_on = [
    cloudflare_record.aws_env_resourcewatch_org_dns_validation,
  ]
}

resource "aws_api_gateway_domain_name" "aws_env_resourcewatch_org_gateway_domain_name" {
  certificate_arn = aws_acm_certificate_validation.aws_env_resourcewatch_org_domain_cert_validation.certificate_arn
  domain_name     = "aws-${var.dns_prefix}.${data.cloudflare_zones.resourcewatch.zones[0].name}"

  depends_on = [
  aws_acm_certificate_validation.aws_env_resourcewatch_org_domain_cert_validation]
}

resource "aws_api_gateway_base_path_mapping" "aws_env_resourcewatch_org_base_path_mapping" {
  api_id      = aws_api_gateway_rest_api.rw_api_gateway.id
  stage_name  = aws_api_gateway_deployment.prod.stage_name
  domain_name = aws_api_gateway_domain_name.aws_env_resourcewatch_org_gateway_domain_name.domain_name
}

// {env}-api.resourcewatch.org
resource "aws_acm_certificate" "env_api_resourcewatch_org_domain_cert" {
  domain_name       = "${var.dns_prefix}-api.${data.cloudflare_zones.resourcewatch.zones[0].name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_record" "env_api_resourcewatch_org_dns_validation" {
  zone_id = data.cloudflare_zones.resourcewatch.zones[0].id
  name    = tolist(aws_acm_certificate.env_api_resourcewatch_org_domain_cert.domain_validation_options)[0].resource_record_name
  value   = trim(tolist(aws_acm_certificate.env_api_resourcewatch_org_domain_cert.domain_validation_options)[0].resource_record_value, ".")
  type    = "CNAME"
  ttl     = 120
}

resource "cloudflare_record" "env_api_resourcewatch_org_dns" {
  zone_id = data.cloudflare_zones.resourcewatch.zones[0].id
  name    = "${var.dns_prefix}-api.${data.cloudflare_zones.resourcewatch.zones[0].name}"
  value   = aws_api_gateway_domain_name.env_api_resourcewatch_org_gateway_domain_name.cloudfront_domain_name
  type    = "CNAME"
  ttl     = 120
}

resource "aws_acm_certificate_validation" "env_api_resourcewatch_org_domain_cert_validation" {
  certificate_arn = aws_acm_certificate.env_api_resourcewatch_org_domain_cert.arn

  depends_on = [
    cloudflare_record.env_api_resourcewatch_org_dns_validation,
  ]
}

resource "aws_api_gateway_domain_name" "env_api_resourcewatch_org_gateway_domain_name" {
  certificate_arn = aws_acm_certificate_validation.env_api_resourcewatch_org_domain_cert_validation.certificate_arn
  domain_name     = "${var.dns_prefix}-api.${data.cloudflare_zones.resourcewatch.zones[0].name}"

  depends_on = [
  aws_acm_certificate_validation.env_api_resourcewatch_org_domain_cert_validation]
}

resource "aws_api_gateway_base_path_mapping" "env_api_resourcewatch_org_base_path_mapping" {
  api_id      = aws_api_gateway_rest_api.rw_api_gateway.id
  stage_name  = aws_api_gateway_deployment.prod.stage_name
  domain_name = aws_api_gateway_domain_name.env_api_resourcewatch_org_gateway_domain_name.domain_name
}

// TODO: if we don't move the globalforestwatch.org DNS into TF, this will have to stay a manual thing
// {env}-api.globalforestwatch.org
resource "aws_acm_certificate" "env_api_globalforestwatch_org_domain_cert" {
  domain_name       = "${var.dns_prefix}-api.globalforestwatch.org"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

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
//  api_id      = aws_api_gateway_rest_api.rw_api_gateway.id
//  stage_name  = aws_api_gateway_deployment.prod.stage_name
//  domain_name = aws_api_gateway_domain_name.env_api_globalforestwatch_org_gateway_domain_name.domain_name
//}