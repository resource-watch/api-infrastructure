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
    api_version = "client.authentication.k8s.io/v1beta1"
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
  stage_name  = aws_api_gateway_stage.prod.stage_name
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
    types = ["REGIONAL"]
  }
  binary_media_types = ["multipart/form-data"]
  api_key_source     = "HEADER"
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "tag:tier"
    values = ["private"]
  }
  filter {
    name   = "vpc-id"
    values = [var.vpc.id]
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
  name                             = "rw-api-apps-nlb"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = data.aws_subnets.private_subnets.ids
  enable_cross_zone_load_balancing = true

  enable_deletion_protection = false
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
  name                             = "rw-api-core-nlb"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = data.aws_subnets.private_subnets.ids
  enable_cross_zone_load_balancing = true

  enable_deletion_protection = false
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
  name                             = "rw-api-gfw-nlb"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = data.aws_subnets.private_subnets.ids
  enable_cross_zone_load_balancing = true

  enable_deletion_protection = false
}

resource "aws_api_gateway_vpc_link" "rw_api_gfw_lb_vpc_link" {
  name        = "RW API gfw LB VPC link"
  description = "VPC link to the RW API service GFW load balancer"
  target_arns = [aws_lb.api_gateway_gfw_nlb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "api_gateway_custom_logs" {
  name = "api_gateway_custom_logs"
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.prod.id
  rest_api_id   = aws_api_gateway_rest_api.rw_api_gateway.id
  stage_name    = "prod"

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_custom_logs.arn
    format          = "($context.requestId), APIKey: $context.identity.apiKey, HTTP Method: $context.httpMethod, Path: $context.resourcePath, Status: $context.status, Errors: $context.error.messageString, Description: custom_log"
  }
}

resource "aws_api_gateway_usage_plan" "open" {
  name        = "open"
  description = "No limits or caps on any endpoints"

  api_stages {
    api_id = aws_api_gateway_rest_api.rw_api_gateway.id
    stage  = aws_api_gateway_stage.prod.stage_name
  }
}

resource "aws_api_gateway_deployment" "prod" {
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id

  triggers = {
    redeployment = sha1(join(",", tolist([
      jsonencode(module.analysis-gee.endpoints),
      jsonencode(module.aqueduct-analysis.endpoints),
      jsonencode(module.arcgis-proxy.endpoints),
      jsonencode(module.arcgis.endpoints),
      jsonencode(module.area.endpoints),
      jsonencode(module.auth.endpoints),
      jsonencode(module.bigquery.endpoints),
      jsonencode(module.biomass.endpoints),
      jsonencode(module.carto.endpoints),
      jsonencode(module.converter.endpoints),
      jsonencode(module.dataset.endpoints),
      jsonencode(module.doc-orchestrator.endpoints),
      jsonencode(module.document-adapter.endpoints),
      jsonencode(module.fires-summary-stats.endpoints),
      jsonencode(module.forest-change.endpoints),
      jsonencode(module.forest-watcher-api.endpoints),
      jsonencode(module.forms.endpoints),
      jsonencode(module.fw-alerts.endpoints),
      jsonencode(module.fw-contextual-layers.endpoints),
      jsonencode(module.fw-teams.endpoints),
      jsonencode(module.gee-tiles.endpoints),
      jsonencode(module.gee.endpoints),
      jsonencode(module.geostore.endpoints),
      jsonencode(module.gfw-adapter.endpoints),
      jsonencode(module.gfw-contact.endpoints),
      jsonencode(module.gfw-guira.endpoints),
      jsonencode(module.gfw-forma.endpoints),
      jsonencode(module.gfw-ogr.endpoints),
      jsonencode(module.gfw-prodes.endpoints),
      jsonencode(module.gfw-umd.endpoints),
      jsonencode(module.gfw-user.endpoints),
      jsonencode(module.gfw-metadata.endpoints),
      jsonencode(module.glad-analysis-tiled.endpoints),
      jsonencode(module.graph-client.endpoints),
      jsonencode(module.gs-pro-config.endpoints),
      jsonencode(module.high-res.endpoints),
      jsonencode(module.imazon.endpoints),
      jsonencode(module.layer.endpoints),
      jsonencode(module.metadata.endpoints),
      jsonencode(module.nexgddp.endpoints),
      jsonencode(module.proxy.endpoints),
      jsonencode(module.query.endpoints),
      jsonencode(module.quicc.endpoints),
      jsonencode(module.rw-lp),
      jsonencode(module.resource-watch-manager),
      jsonencode(module.salesforce-connector),
      jsonencode(module.story),
      jsonencode(module.subscriptions),
      jsonencode(module.task-executor.endpoints),
      jsonencode(module.true-color-tiles.endpoints),
      jsonencode(module.viirs-fires.endpoints),
      jsonencode(module.vocabulary.endpoints),
      jsonencode(module.webshot.endpoints),
      jsonencode(module.widget.endpoints),
      jsonencode(module.v1_redirect.endpoints),
    ])))
  }

  lifecycle {
    create_before_destroy = true
  }
}

#
# Endpoint creation
#

// Base API Gateway resources
module "v1_resource" {
  source      = "./microservices/resource"
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.rw_api_gateway.root_resource_id
  path_part   = "v1"
}

module "v2_resource" {
  source      = "./microservices/resource"
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.rw_api_gateway.root_resource_id
  path_part   = "v2"
}

module "v3_resource" {
  source      = "./microservices/resource"
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.rw_api_gateway.root_resource_id
  path_part   = "v3"
}

// /v1 200 response, needed by FW
resource "aws_api_gateway_method" "get_v1_endpoint_method" {
  rest_api_id   = aws_api_gateway_rest_api.rw_api_gateway.id
  resource_id   = module.v1_resource.aws_api_gateway_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_v1_endpoint_integration" {
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  resource_id = module.v1_resource.aws_api_gateway_resource.id
  http_method = aws_api_gateway_method.get_v1_endpoint_method.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" : "{\"statusCode\": 200}"
  }
  depends_on = [aws_api_gateway_method.get_v1_endpoint_method]
}

resource "aws_api_gateway_method_response" "get_v1_endpoint_method_response" {
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  resource_id = module.v1_resource.aws_api_gateway_resource.id
  http_method = aws_api_gateway_method.get_v1_endpoint_method.http_method
  status_code = 200
}

resource "aws_api_gateway_integration_response" "get_v1_endpoint_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  resource_id = module.v1_resource.aws_api_gateway_resource.id
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

// /{.*} redirect to /v1/{$1}
module "v1_redirect" {
  source           = "./v1-redirect"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  target_domain    = aws_api_gateway_domain_name.aws_env_resourcewatch_org_gateway_domain_name.domain_name
  root_resource_id = aws_api_gateway_rest_api.rw_api_gateway.root_resource_id
}

// /v1/gfw-metadata proxies to external server
module "gfw-metadata" {
  source      = "./microservices/gfw-metadata"
  api_gateway = aws_api_gateway_rest_api.rw_api_gateway
  v1_resource = module.v1_resource.aws_api_gateway_resource
}

module "analysis-gee" {
  source           = "./microservices/analysis-gee"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key
  v2_resource      = module.v2_resource.aws_api_gateway_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.gfw_autoscaling_group.names.0,
  ]

  depends_on = [
    module.v1_resource,
    module.v2_resource
  ]
}

module "aqueduct-analysis" {
  source           = "./microservices/aqueduct-analysis"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_gfw_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key

  eks_asg_names = [
    data.aws_autoscaling_groups.gfw_autoscaling_group.names.0
  ]
}

module "arcgis" {
  source                    = "./microservices/arcgis"
  api_gateway               = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca                = var.cluster_ca
  cluster_endpoint          = var.cluster_endpoint
  cluster_name              = var.cluster_name
  x_rw_domain               = var.x_rw_domain
  vpc                       = var.vpc
  vpc_link                  = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  connection_type           = "VPC_LINK"
  require_api_key           = var.require_api_key
  v1_resource               = module.v1_resource.aws_api_gateway_resource
  v1_query_resource         = module.query.v1_query_resource
  v1_download_resource      = module.query.v1_download_resource
  v1_fields_resource        = module.query.v1_fields_resource
  v1_rest_datasets_resource = module.dataset.v1_rest_datasets_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0,
  ]

  depends_on = [
    module.dataset,
  ]
}

module "arcgis-proxy" {
  source           = "./microservices/arcgis-proxy"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0,
  ]
}

module "area" {
  source           = "./microservices/area"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key
  v2_resource      = module.v2_resource.aws_api_gateway_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0
  ]

  depends_on = [
    module.v1_resource,
    module.v2_resource
  ]
}

module "auth" {
  source           = "./microservices/authorization"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_core_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key
  root_resource_id = aws_api_gateway_rest_api.rw_api_gateway.root_resource_id

  eks_asg_names = [
    data.aws_autoscaling_groups.core_autoscaling_group.names.0
  ]
}

module "bigquery" {
  source                    = "./microservices/bigquery"
  api_gateway               = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca                = var.cluster_ca
  cluster_endpoint          = var.cluster_endpoint
  cluster_name              = var.cluster_name
  x_rw_domain               = var.x_rw_domain
  vpc                       = var.vpc
  vpc_link                  = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  connection_type           = "VPC_LINK"
  require_api_key           = var.require_api_key
  v1_resource               = module.v1_resource.aws_api_gateway_resource
  v1_query_resource         = module.query.v1_query_resource
  v1_download_resource      = module.query.v1_download_resource
  v1_fields_resource        = module.query.v1_fields_resource
  v1_rest_datasets_resource = module.dataset.v1_rest_datasets_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0,
  ]

  depends_on = [
    module.dataset,
    module.query,
  ]
}

module "biomass" {
  source                   = "./microservices/biomass"
  api_gateway              = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca               = var.cluster_ca
  cluster_endpoint         = var.cluster_endpoint
  cluster_name             = var.cluster_name
  x_rw_domain              = var.x_rw_domain
  vpc                      = var.vpc
  vpc_link                 = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  connection_type          = "VPC_LINK"
  require_api_key          = var.require_api_key
  v1_resource              = module.v1_resource.aws_api_gateway_resource
  v1_biomass_loss_resource = module.analysis-gee.v1_biomass_loss_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0,
  ]

  depends_on = [
    module.analysis-gee
  ]
}

module "carto" {
  source                    = "./microservices/carto"
  api_gateway               = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca                = var.cluster_ca
  cluster_endpoint          = var.cluster_endpoint
  cluster_name              = var.cluster_name
  x_rw_domain               = var.x_rw_domain
  vpc                       = var.vpc
  vpc_link                  = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  connection_type           = "VPC_LINK"
  require_api_key           = var.require_api_key
  v1_resource               = module.v1_resource.aws_api_gateway_resource
  v1_query_resource         = module.query.v1_query_resource
  v1_download_resource      = module.query.v1_download_resource
  v1_fields_resource        = module.query.v1_fields_resource
  v1_rest_datasets_resource = module.dataset.v1_rest_datasets_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0,
  ]

  depends_on = [
    module.dataset,
    module.query,
  ]
}

module "converter" {
  source           = "./microservices/converter"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key
  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0
  ]
}

module "dataset" {
  source           = "./microservices/dataset"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0
  ]
}

module "doc-orchestrator" {
  source           = "./microservices/doc-orchestrator"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0
  ]
}

module "document-adapter" {
  source                 = "./microservices/document-adapter"
  api_gateway            = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca             = var.cluster_ca
  cluster_endpoint       = var.cluster_endpoint
  cluster_name           = var.cluster_name
  x_rw_domain            = var.x_rw_domain
  vpc                    = var.vpc
  vpc_link               = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  connection_type        = "VPC_LINK"
  require_api_key        = var.require_api_key
  v1_resource            = module.v1_resource.aws_api_gateway_resource
  v1_dataset_id_resource = module.dataset.v1_dataset_id_resource
  v1_query_resource      = module.query.v1_query_resource
  v1_download_resource   = module.query.v1_download_resource
  v1_fields_resource     = module.query.v1_fields_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0
  ]

  depends_on = [
    module.dataset,
    module.query,
  ]
}

module "fires-summary-stats" {
  source           = "./microservices/fires-summary-stats"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0
  ]
}

module "forest-watcher-api" {
  source           = "./microservices/forest-watcher-api"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key
  backend_url      = var.fw_backend_url

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0
  ]
}

module "forest-change" {
  source           = "./microservices/forest-change"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key

  eks_asg_names = [
    data.aws_autoscaling_groups.gfw_autoscaling_group.names.0
  ]
}

module "forms" {
  source           = "./microservices/forms"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_gfw_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key
  backend_url      = var.fw_backend_url

  eks_asg_names = [
    data.aws_autoscaling_groups.gfw_autoscaling_group.names.0
  ]
}

module "fw-alerts" {
  source           = "./microservices/fw-alerts"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_gfw_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key
  backend_url      = var.fw_backend_url

  eks_asg_names = [
    data.aws_autoscaling_groups.gfw_autoscaling_group.names.0,
  ]
}

module "fw-contextual-layers" {
  source           = "./microservices/fw-contextual-layers"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_gfw_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key
  backend_url      = var.fw_backend_url

  eks_asg_names = [
    data.aws_autoscaling_groups.gfw_autoscaling_group.names.0,
  ]
}

module "fw-teams" {
  source           = "./microservices/fw-teams"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_gfw_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key
  backend_url      = var.fw_backend_url

  eks_asg_names = [
    data.aws_autoscaling_groups.gfw_autoscaling_group.names.0
  ]
}

module "gee" {
  source                    = "./microservices/gee"
  api_gateway               = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca                = var.cluster_ca
  cluster_endpoint          = var.cluster_endpoint
  cluster_name              = var.cluster_name
  x_rw_domain               = var.x_rw_domain
  vpc                       = var.vpc
  vpc_link                  = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  connection_type           = "VPC_LINK"
  require_api_key           = var.require_api_key
  v1_resource               = module.v1_resource.aws_api_gateway_resource
  v1_query_resource         = module.query.v1_query_resource
  v1_download_resource      = module.query.v1_download_resource
  v1_fields_resource        = module.query.v1_fields_resource
  v1_rest_datasets_resource = module.dataset.v1_rest_datasets_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0
  ]

  depends_on = [
    module.dataset
  ]
}

module "gee-tiles" {
  source               = "./microservices/gee-tiles"
  api_gateway          = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca           = var.cluster_ca
  cluster_endpoint     = var.cluster_endpoint
  cluster_name         = var.cluster_name
  x_rw_domain          = var.x_rw_domain
  vpc                  = var.vpc
  vpc_link             = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  connection_type      = "VPC_LINK"
  require_api_key      = var.require_api_key
  v1_resource          = module.v1_resource.aws_api_gateway_resource
  v1_layer_resource    = module.layer.v1_layer_resource
  v1_layer_id_resource = module.layer.v1_layer_id_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0
  ]

  depends_on = [
    module.layer
  ]
}

module "geostore" {
  source           = "./microservices/geostore"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key
  v2_resource      = module.v2_resource.aws_api_gateway_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0
  ]
}

module "gfw-adapter" {
  source                    = "./microservices/gfw-adapter"
  api_gateway               = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca                = var.cluster_ca
  cluster_endpoint          = var.cluster_endpoint
  cluster_name              = var.cluster_name
  x_rw_domain               = var.x_rw_domain
  vpc                       = var.vpc
  vpc_link                  = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  connection_type           = "VPC_LINK"
  require_api_key           = var.require_api_key
  v1_resource               = module.v1_resource.aws_api_gateway_resource
  v1_query_resource         = module.query.v1_query_resource
  v1_download_resource      = module.query.v1_download_resource
  v1_fields_resource        = module.query.v1_fields_resource
  v1_rest_datasets_resource = module.dataset.v1_rest_datasets_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0,
  ]

  depends_on = [
    module.dataset,
    module.query,
  ]
}

module "gfw-contact" {
  source           = "./microservices/gfw-contact"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_gfw_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key

  eks_asg_names = [
    data.aws_autoscaling_groups.gfw_autoscaling_group.names.0
  ]
}

module "gfw-forma" {
  source           = "./microservices/gfw-forma"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0
  ]
}

module "gfw-guira" {
  source           = "./microservices/gfw-guira"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key
  v2_resource      = module.v2_resource.aws_api_gateway_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0
  ]
}

module "gfw-ogr" {
  source           = "./microservices/gfw-ogr"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key
  v2_resource      = module.v2_resource.aws_api_gateway_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0
  ]
}


module "gfw-prodes" {
  source           = "./microservices/gfw-prodes"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key
  v2_resource      = module.v2_resource.aws_api_gateway_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0
  ]
}

module "gfw-umd" {
  source                    = "./microservices/gfw-umd"
  api_gateway               = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca                = var.cluster_ca
  cluster_endpoint          = var.cluster_endpoint
  cluster_name              = var.cluster_name
  x_rw_domain               = var.x_rw_domain
  vpc                       = var.vpc
  vpc_link                  = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  connection_type           = "VPC_LINK"
  require_api_key           = var.require_api_key
  v1_resource               = module.v1_resource.aws_api_gateway_resource
  v2_resource               = module.v2_resource.aws_api_gateway_resource
  v3_resource               = module.v3_resource.aws_api_gateway_resource
  v1_umd_loss_gain_resource = module.analysis-gee.v1_umd_loss_gain_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.gfw_autoscaling_group.names.0,
  ]
}

module "gfw-user" {
  source           = "./microservices/gfw-user"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_gfw_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  v2_resource      = module.v2_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key

  eks_asg_names = [
    data.aws_autoscaling_groups.gfw_autoscaling_group.names.0,
  ]
}

module "glad-analysis-tiled" {
  source                  = "./microservices/glad-analysis-tiled"
  api_gateway             = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca              = var.cluster_ca
  cluster_endpoint        = var.cluster_endpoint
  cluster_name            = var.cluster_name
  x_rw_domain             = var.x_rw_domain
  vpc                     = var.vpc
  vpc_link                = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  connection_type         = "VPC_LINK"
  require_api_key         = var.require_api_key
  v1_resource             = module.v1_resource.aws_api_gateway_resource
  v1_glad_alerts_resource = module.fires-summary-stats.v1_glad_alerts_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0,
  ]

  depends_on = [
    module.fires-summary-stats
  ]
}

module "graph-client" {
  source           = "./microservices/graph-client"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0,
  ]
}

module "gs-pro-config" {
  source           = "./microservices/gs-pro-config"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0,
  ]
}

module "high-res" {
  source           = "./microservices/high-res"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key

  eks_asg_names = [
    data.aws_autoscaling_groups.gfw_autoscaling_group.names.0
  ]
}

module "imazon" {
  source           = "./microservices/imazon"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key
  v2_resource      = module.v2_resource.aws_api_gateway_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0,
  ]

  depends_on = [
    module.v1_resource,
    module.v2_resource
  ]
}

module "layer" {
  source                 = "./microservices/layer"
  api_gateway            = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca             = var.cluster_ca
  cluster_endpoint       = var.cluster_endpoint
  cluster_name           = var.cluster_name
  x_rw_domain            = var.x_rw_domain
  vpc                    = var.vpc
  vpc_link               = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  connection_type        = "VPC_LINK"
  require_api_key        = var.require_api_key
  v1_resource            = module.v1_resource.aws_api_gateway_resource
  v1_dataset_id_resource = module.dataset.v1_dataset_id_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0
  ]

  depends_on = [
    module.v1_resource,
    module.dataset,
  ]
}

module "metadata" {
  source                           = "./microservices/metadata"
  api_gateway                      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca                       = var.cluster_ca
  cluster_endpoint                 = var.cluster_endpoint
  cluster_name                     = var.cluster_name
  x_rw_domain                      = var.x_rw_domain
  vpc                              = var.vpc
  vpc_link                         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  connection_type                  = "VPC_LINK"
  require_api_key                  = var.require_api_key
  v1_resource                      = module.v1_resource.aws_api_gateway_resource
  v1_dataset_resource              = module.dataset.v1_dataset_resource
  v1_dataset_id_resource           = module.dataset.v1_dataset_id_resource
  v1_dataset_id_layer_resource     = module.layer.v1_dataset_id_layer_resource
  v1_dataset_id_layer_id_resource  = module.layer.v1_dataset_id_layer_id_resource
  v1_dataset_id_widget_resource    = module.widget.v1_dataset_id_widget_resource
  v1_dataset_id_widget_id_resource = module.widget.v1_dataset_id_widget_id_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0,
  ]
}

module "nexgddp" {
  source                    = "./microservices/nexgddp"
  api_gateway               = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca                = var.cluster_ca
  cluster_endpoint          = var.cluster_endpoint
  cluster_name              = var.cluster_name
  x_rw_domain               = var.x_rw_domain
  vpc                       = var.vpc
  vpc_link                  = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  connection_type           = "VPC_LINK"
  require_api_key           = var.require_api_key
  v1_resource               = module.v1_resource.aws_api_gateway_resource
  v1_query_resource         = module.query.v1_query_resource
  v1_download_resource      = module.query.v1_download_resource
  v1_fields_resource        = module.query.v1_fields_resource
  v1_rest_datasets_resource = module.dataset.v1_rest_datasets_resource
  v1_layer_resource         = module.layer.v1_layer_resource
  v1_layer_id_tile_resource = module.gee-tiles.v1_gee_tiles_layer_id_tile_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0,
  ]

  depends_on = [
    module.v1_resource,
    module.layer,
    module.gee-tiles
  ]
}

module "proxy" {
  source           = "./microservices/proxy"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0
  ]

  depends_on = [
    module.v1_resource,
  ]
}

module "query" {
  source           = "./microservices/query"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0,
  ]

  depends_on = [
    module.v1_resource
  ]
}

module "quicc" {
  source           = "./microservices/quicc"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key
  v1_resource      = module.v1_resource.aws_api_gateway_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0,
  ]

  depends_on = [
    module.v1_resource
  ]
}

module "rw-lp" {
  source           = "./microservices/rw-lp"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0
  ]
}

module "resource-watch-manager" {
  source           = "./microservices/resource-watch-manager"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0
  ]
}

module "salesforce-connector" {
  source           = "./microservices/salesforce-connector"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key

  eks_asg_names = [
    data.aws_autoscaling_groups.gfw_autoscaling_group.names.0,
  ]
}

module "story" {
  source           = "./microservices/story"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0,
  ]
}

module "subscriptions" {
  source           = "./microservices/subscriptions"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0,
  ]
}

module "task-executor" {
  source           = "./microservices/task-executor"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0
  ]
}

module "true-color-tiles" {
  source           = "./microservices/true-color-tiles"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key

  eks_asg_names = [
    data.aws_autoscaling_groups.gfw_autoscaling_group.names.0
  ]
}

module "viirs-fires" {
  source           = "./microservices/viirs-fires"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key
  v1_resource      = module.v1_resource.aws_api_gateway_resource
  v2_resource      = module.v2_resource.aws_api_gateway_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0,
  ]
}

module "vocabulary" {
  source                           = "./microservices/vocabulary"
  api_gateway                      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca                       = var.cluster_ca
  cluster_endpoint                 = var.cluster_endpoint
  cluster_name                     = var.cluster_name
  x_rw_domain                      = var.x_rw_domain
  vpc                              = var.vpc
  vpc_link                         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  connection_type                  = "VPC_LINK"
  require_api_key                  = var.require_api_key
  v1_resource                      = module.v1_resource.aws_api_gateway_resource
  v1_dataset_resource              = module.dataset.v1_dataset_resource
  v1_dataset_id_resource           = module.dataset.v1_dataset_id_resource
  v1_dataset_id_layer_resource     = module.layer.v1_dataset_id_layer_resource
  v1_dataset_id_layer_id_resource  = module.layer.v1_dataset_id_layer_id_resource
  v1_dataset_id_widget_resource    = module.widget.v1_dataset_id_widget_resource
  v1_dataset_id_widget_id_resource = module.widget.v1_dataset_id_widget_id_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0,
  ]
}

module "webshot" {
  source           = "./microservices/webshot"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  x_rw_domain      = var.x_rw_domain
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  connection_type  = "VPC_LINK"
  require_api_key  = var.require_api_key
  v1_resource      = module.v1_resource.aws_api_gateway_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0,
  ]
}

module "widget" {
  source                 = "./microservices/widget"
  api_gateway            = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca             = var.cluster_ca
  cluster_endpoint       = var.cluster_endpoint
  cluster_name           = var.cluster_name
  x_rw_domain            = var.x_rw_domain
  vpc                    = var.vpc
  vpc_link               = aws_api_gateway_vpc_link.rw_api_apps_lb_vpc_link
  connection_type        = "VPC_LINK"
  require_api_key        = var.require_api_key
  v1_resource            = module.v1_resource.aws_api_gateway_resource
  v1_dataset_id_resource = module.dataset.v1_dataset_id_resource

  eks_asg_names = [
    data.aws_autoscaling_groups.apps_autoscaling_group.names.0
  ]

  depends_on = [
    module.v1_resource,
    module.dataset,
  ]
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
  security_policy = "TLS_1_2"

  depends_on = [
    aws_acm_certificate_validation.aws_env_resourcewatch_org_domain_cert_validation
  ]
}

resource "aws_api_gateway_base_path_mapping" "aws_env_resourcewatch_org_base_path_mapping" {
  api_id      = aws_api_gateway_rest_api.rw_api_gateway.id
  stage_name  = aws_api_gateway_stage.prod.stage_name
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
  security_policy = "TLS_1_2"

  depends_on = [
    aws_acm_certificate_validation.env_api_resourcewatch_org_domain_cert_validation
  ]
}

resource "aws_api_gateway_base_path_mapping" "env_api_resourcewatch_org_base_path_mapping" {
  api_id      = aws_api_gateway_rest_api.rw_api_gateway.id
  stage_name  = aws_api_gateway_stage.prod.stage_name
  domain_name = aws_api_gateway_domain_name.env_api_resourcewatch_org_gateway_domain_name.domain_name
}
