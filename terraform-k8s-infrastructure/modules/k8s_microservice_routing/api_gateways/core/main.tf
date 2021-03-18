// AWS NLB between API Gateway and EKS

data "aws_subnet_ids" "private_subnets" {
  vpc_id = var.vpc.id

  tags = {
    tier = "private"
  }
}

data "aws_autoscaling_groups" "eks_autoscaling_groups" {
  filter {
    name = "key"
    values = [
      "kubernetes.io/cluster/core-k8s-cluster-${var.environment}"]
  }

  filter {
    name = "value"
    values = [
      "owned"]
  }
}

resource "aws_lb" "api_gateway_nlb" {
  name               = "rw-api-core-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = data.aws_subnet_ids.private_subnets.ids

  enable_deletion_protection = true
}

resource "aws_api_gateway_vpc_link" "rw_api_lb_vpc_link" {
  name        = "RW API Core LB VPC link"
  description = "VPC link to the RW API service load balancer"
  target_arns = [aws_lb.api_gateway_nlb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

module "rw_api_core_api_gateway" {
  source      = "../base"
  name_suffix = "core"
  dns_prefix  = var.dns_prefix
  endpoint_list = list(
    jsonencode(module.arcgis.endpoints),
    jsonencode(module.auth.endpoints),
    jsonencode(module.bigquery.endpoints),
    jsonencode(module.carto.endpoints),
    jsonencode(module.converter.endpoints),
    jsonencode(module.ct.endpoints),
    jsonencode(module.dataset.endpoints),
    jsonencode(module.doc-orchestrator.endpoints),
    jsonencode(module.doc_swagger.endpoints),
    jsonencode(module.document-adapter.endpoints),
    jsonencode(module.fires-summary-stats.endpoints),
    jsonencode(module.gee-tiles.endpoints),
    jsonencode(module.gee.endpoints),
    jsonencode(module.geostore.endpoints),
    jsonencode(module.graph-client.endpoints),
    jsonencode(module.layer.endpoints),
    jsonencode(module.metadata.endpoints),
    jsonencode(module.query.endpoints),
    jsonencode(module.rw-lp),
    jsonencode(module.task_executor.endpoints),
    jsonencode(module.vocabulary.endpoints),
    jsonencode(module.webshot.endpoints),
    jsonencode(module.widget.endpoints),
  )
}

// Base API Gateway resources
resource "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = module.rw_api_core_api_gateway.aws_api_gateway_rest_api.id
  parent_id   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api.root_resource_id
  path_part   = "v1"
}

resource "aws_api_gateway_resource" "v2_resource" {
  rest_api_id = module.rw_api_core_api_gateway.aws_api_gateway_rest_api.id
  parent_id   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api.root_resource_id
  path_part   = "v2"
}

resource "aws_api_gateway_resource" "v3_resource" {
  rest_api_id = module.rw_api_core_api_gateway.aws_api_gateway_rest_api.id
  parent_id   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api.root_resource_id
  path_part   = "v3"
}

// /documentation uses doc-swagger MS (no CT)
module "doc_swagger" {
  source        = "../../microservices/doc-swagger"
  api_gateway   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

// Import routes per MS, one by one
module "ct" {
  source        = "../../microservices/ct"
  api_gateway   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "arcgis" {
  source        = "../../microservices/arcgis"
  api_gateway   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names

  depends_on = [
    module.dataset,
    module.query,
  ]
}

module "auth" {
  source        = "../../microservices/authorization"
  api_gateway   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "bigquery" {
  source        = "../../microservices/bigquery"
  api_gateway   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names

  depends_on = [
    module.dataset,
    module.query,
  ]
}

module "carto" {
  source        = "../../microservices/carto"
  api_gateway   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names

  depends_on = [
    module.dataset,
    module.query,
  ]
}

module "converter" {
  source        = "../../microservices/converter"
  api_gateway   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "dataset" {
  source        = "../../microservices/dataset"
  api_gateway   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "doc-orchestrator" {
  source        = "../../microservices/doc-orchestrator"
  api_gateway   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "document-adapter" {
  source        = "../../microservices/document-adapter"
  api_gateway   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names

  depends_on = [
    module.dataset,
    module.query,
  ]
}

module "fires-summary-stats" {
  source        = "../../microservices/fires-summary-stats"
  api_gateway   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "gee" {
  source        = "../../microservices/gee"
  api_gateway   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names

  depends_on = [
    module.dataset
  ]
}

module "gee-tiles" {
  source        = "../../microservices/gee-tiles"
  api_gateway   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names

  depends_on = [
    module.layer
  ]
}

module "geostore" {
  source        = "../../microservices/geostore"
  api_gateway   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "graph-client" {
  source        = "../../microservices/graph-client"
  api_gateway   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "layer" {
  source        = "../../microservices/layer"
  api_gateway   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names

  depends_on = [
    module.dataset,
  ]
}

module "metadata" {
  source        = "../../microservices/metadata"
  api_gateway   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names

  depends_on = [
    module.dataset,
    module.layer,
    module.widget,
  ]
}

module "query" {
  source        = "../../microservices/query"
  api_gateway   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "rw-lp" {
  source        = "../../microservices/rw-lp"
  api_gateway   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "task_executor" {
  source        = "../../microservices/task-executor"
  api_gateway   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "viirs_fires" {
  source        = "../../microservices/viirs-fires"
  api_gateway   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "vocabulary" {
  source        = "../../microservices/vocabulary"
  api_gateway   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names

  depends_on = [
    module.dataset,
    module.widget,
    module.layer,
  ]
}

module "webshot" {
  source        = "../../microservices/webshot"
  api_gateway   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "widget" {
  source        = "../../microservices/widget"
  api_gateway   = module.rw_api_core_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names

  depends_on = [
    module.dataset,
  ]
}