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

data "aws_autoscaling_groups" "eks_autoscaling_groups" {
  filter {
    name   = "key"
    values = ["kubernetes.io/cluster/core-k8s-cluster-${var.environment}"]
  }

  filter {
    name   = "value"
    values = ["owned"]
  }
}

resource "aws_lb" "api_gateway_nlb" {
  name               = "rw-api-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = data.aws_subnet_ids.private_subnets.ids

  enable_deletion_protection = true
}

resource "aws_api_gateway_vpc_link" "rw_api_lb_vpc_link" {
  name        = "RW API LB VPC link"
  description = "VPC link to the RW API service load balancer"
  target_arns = [aws_lb.api_gateway_nlb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_deployment" "prod" {
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  stage_name  = "prod"

  triggers = {
    redeployment = sha1(join(",", list(
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
      jsonencode(module.ct.endpoints),
      jsonencode(module.dataset.endpoints),
      jsonencode(module.doc-orchestrator.endpoints),
      jsonencode(module.doc_swagger.endpoints),
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
      jsonencode(module.gfw-guira.endpoints),
      jsonencode(module.gfw-forma.endpoints),
      jsonencode(module.gfw-ogr.endpoints),
      jsonencode(module.gfw-prodes.endpoints),
      jsonencode(module.gfw-umd.endpoints),
      jsonencode(module.gfw-user.endpoints),
      jsonencode(module.gfw_metadata.endpoints),
      jsonencode(module.graph-client.endpoints),
      jsonencode(module.layer.endpoints),
      jsonencode(module.metadata.endpoints),
      jsonencode(module.nexgddp.endpoints),
      jsonencode(module.proxy.endpoints),
      jsonencode(module.query.endpoints),
      jsonencode(module.query.endpoints),
      jsonencode(module.rw-lp),
      jsonencode(module.resource-watch-manager),
      jsonencode(module.task_executor.endpoints),
      jsonencode(module.vocabulary.endpoints),
      jsonencode(module.webshot.endpoints),
      jsonencode(module.widget.endpoints),
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

// /{.*} redirect to /v1/{$1}
module "v1_redirect" {
  source      = "./v1-redirect"
  api_gateway = aws_api_gateway_rest_api.rw_api_gateway
  target_domain = aws_api_gateway_domain_name.aws_env_resourcewatch_org_gateway_domain_name.domain_name
}

// /v1/gfw-metadata proxies to external server
module "gfw_metadata" {
  source      = "./gfw-metadata"
  api_gateway = aws_api_gateway_rest_api.rw_api_gateway
}

// /documentation uses doc-swagger MS (no CT)
module "doc_swagger" {
  source           = "./doc-swagger"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}


// Import routes per MS, one by one
module "ct" {
  source           = "./ct"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "analysis-gee" {
  source           = "./analysis-gee"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "aqueduct-analysis" {
  source           = "./aqueduct-analysis"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "arcgis" {
  source           = "./arcgis"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names

  depends_on = [
    module.dataset,
    module.query,
  ]
}

module "arcgis-proxy" {
  source           = "./arcgis-proxy"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "area" {
  source           = "./area"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "auth" {
  source           = "./authorization"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "bigquery" {
  source           = "./bigquery"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names

  depends_on = [
    module.dataset,
    module.query,
  ]
}

module "biomass" {
  source           = "./biomass"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names

  depends_on = [
    module.analysis-gee
  ]
}

module "carto" {
  source           = "./carto"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names

  depends_on = [
    module.dataset,
    module.query,
  ]
}

module "converter" {
  source           = "./converter"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "dataset" {
  source           = "./dataset"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names

  depends_on = [
    aws_api_gateway_resource.v1_resource
  ]
}

module "doc-orchestrator" {
  source           = "./doc-orchestrator"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "document-adapter" {
  source           = "./document-adapter"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names

  depends_on = [
    module.dataset,
    module.query,
  ]
}

module "fires-summary-stats" {
  source           = "./fires-summary-stats"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "forest-watcher-api" {
  source           = "./forest-watcher-api"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "forest-change" {
  source           = "./forest-change"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "forms" {
  source           = "./forms"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "fw-alerts" {
  source           = "./fw-alerts"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "fw-contextual-layers" {
  source           = "./fw-contextual-layers"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "fw-teams" {
  source           = "./fw-teams"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "gee" {
  source           = "./gee"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names

  depends_on = [
    module.dataset
  ]
}

module "gee-tiles" {
  source           = "./gee-tiles"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names

  depends_on = [
    module.layer
  ]
}

module "geostore" {
  source           = "./geostore"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "gfw-forma" {
  source           = "./gfw-forma"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "gfw-guira" {
  source           = "./gfw-guira"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "gfw-ogr" {
  source           = "./gfw-ogr"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "gfw-prodes" {
  source           = "./gfw-prodes"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "gfw-umd" {
  source           = "./gfw-umd"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "gfw-user" {
  source           = "./gfw-user"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "graph-client" {
  source           = "./graph-client"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "layer" {
  source           = "./layer"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names

  depends_on = [
    module.dataset,
  ]
}

module "metadata" {
  source           = "./metadata"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names

  depends_on = [
    module.dataset,
    module.layer,
    module.widget,
  ]
}

module "nexgddp" {
  source           = "./nexgddp"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names

  depends_on = [
    module.layer,
    module.gee-tiles
  ]
}

module "proxy" {
  source           = "./proxy"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "query" {
  source           = "./query"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "rw-lp" {
  source           = "./rw-lp"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "resource-watch-manager" {
  source           = "./resource-watch-manager"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "task_executor" {
  source           = "./task-executor"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "viirs_fires" {
  source           = "./viirs-fires"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "vocabulary" {
  source           = "./vocabulary"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names

  depends_on = [
    module.dataset,
    module.widget,
    module.layer,
  ]
}

module "webshot" {
  source           = "./webshot"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "widget" {
  source           = "./widget"
  api_gateway      = aws_api_gateway_rest_api.rw_api_gateway
  cluster_ca       = var.cluster_ca
  cluster_endpoint = var.cluster_endpoint
  cluster_name     = var.cluster_name
  load_balancer    = aws_lb.api_gateway_nlb
  vpc              = var.vpc
  vpc_link         = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names    = data.aws_autoscaling_groups.eks_autoscaling_groups.names

  depends_on = [
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