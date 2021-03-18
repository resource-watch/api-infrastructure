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
  name               = "rw-api-gfw-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = data.aws_subnet_ids.private_subnets.ids

  enable_deletion_protection = true
}

resource "aws_api_gateway_vpc_link" "rw_api_lb_vpc_link" {
  name        = "RW API GFW LB VPC link"
  description = "VPC link to the RW API service load balancer"
  target_arns = [aws_lb.api_gateway_nlb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

module "rw_api_gfw_api_gateway" {
  source      = "../base"
  name_suffix = "gfw"
  dns_prefix  = var.dns_prefix
  endpoint_list = list(
    jsonencode(module.analysis-gee.endpoints),
    jsonencode(module.arcgis-proxy.endpoints),
    jsonencode(module.area.endpoints),
    jsonencode(module.forest-change.endpoints),
    jsonencode(module.gfw-forma.endpoints),
    jsonencode(module.gfw-guira.endpoints),
    jsonencode(module.gfw_metadata.endpoints),
  )
}

// Base API Gateway resources
resource "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = module.rw_api_gfw_api_gateway.aws_api_gateway_rest_api.id
  parent_id   = module.rw_api_gfw_api_gateway.aws_api_gateway_rest_api.root_resource_id
  path_part   = "v1"
}

resource "aws_api_gateway_resource" "v2_resource" {
  rest_api_id = module.rw_api_gfw_api_gateway.aws_api_gateway_rest_api.id
  parent_id   = module.rw_api_gfw_api_gateway.aws_api_gateway_rest_api.root_resource_id
  path_part   = "v2"
}

resource "aws_api_gateway_resource" "v3_resource" {
  rest_api_id = module.rw_api_gfw_api_gateway.aws_api_gateway_rest_api.id
  parent_id   = module.rw_api_gfw_api_gateway.aws_api_gateway_rest_api.root_resource_id
  path_part   = "v3"
}

module "analysis-gee" {
  source        = "../../microservices/analysis-gee"
  api_gateway   = module.rw_api_gfw_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "arcgis-proxy" {
  source        = "../../microservices/arcgis-proxy"
  api_gateway   = module.rw_api_gfw_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "area" {
  source        = "../../microservices/area"
  api_gateway   = module.rw_api_gfw_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "forest-change" {
  source        = "../../microservices/forest-change"
  api_gateway   = module.rw_api_gfw_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "gfw-forma" {
  source        = "../../microservices/gfw-forma"
  api_gateway   = module.rw_api_gfw_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "gfw-guira" {
  source        = "../../microservices/gfw-guira"
  api_gateway   = module.rw_api_gfw_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

// Nginx reverse proxy config, remapped

// /v1/gfw-metadata proxies to external server
module "gfw_metadata" {
  source      = "../../microservices/gfw-metadata"
  api_gateway = module.rw_api_gfw_api_gateway.aws_api_gateway_rest_api
}