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
  name               = "rw-api-misc-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = data.aws_subnet_ids.private_subnets.ids

  enable_deletion_protection = true
}

resource "aws_api_gateway_vpc_link" "rw_api_lb_vpc_link" {
  name        = "RW API Misc LB VPC link"
  description = "VPC link to the RW API service load balancer"
  target_arns = [aws_lb.api_gateway_nlb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

module "rw_api_misc_api_gateway" {
  source      = "../base"
  name_suffix = "misc"
  dns_prefix  = var.dns_prefix
  endpoint_list = list(
    jsonencode(module.aqueduct-analysis.endpoints),
    jsonencode(module.biomass.endpoints),
    jsonencode(module.resource-watch-manager)
  )
}

// Base API Gateway resources
resource "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = module.rw_api_misc_api_gateway.aws_api_gateway_rest_api.id
  parent_id   = module.rw_api_misc_api_gateway.aws_api_gateway_rest_api.root_resource_id
  path_part   = "v1"
}

resource "aws_api_gateway_resource" "v2_resource" {
  rest_api_id = module.rw_api_misc_api_gateway.aws_api_gateway_rest_api.id
  parent_id   = module.rw_api_misc_api_gateway.aws_api_gateway_rest_api.root_resource_id
  path_part   = "v2"
}

resource "aws_api_gateway_resource" "v3_resource" {
  rest_api_id = module.rw_api_misc_api_gateway.aws_api_gateway_rest_api.id
  parent_id   = module.rw_api_misc_api_gateway.aws_api_gateway_rest_api.root_resource_id
  path_part   = "v3"
}

module "aqueduct-analysis" {
  source        = "../../microservices/aqueduct-analysis"
  api_gateway   = module.rw_api_misc_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}


module "biomass" {
  source        = "../../microservices/biomass"
  api_gateway   = module.rw_api_misc_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}

module "resource-watch-manager" {
  source        = "../../microservices/resource-watch-manager"
  api_gateway   = module.rw_api_misc_api_gateway.aws_api_gateway_rest_api
  load_balancer = aws_lb.api_gateway_nlb
  vpc           = var.vpc
  vpc_link      = aws_api_gateway_vpc_link.rw_api_lb_vpc_link
  eks_asg_names = data.aws_autoscaling_groups.eks_autoscaling_groups.names
}


// /v1 200 response, needed by FW
resource "aws_api_gateway_method" "get_v1_endpoint_method" {
  rest_api_id   = module.rw_api_misc_api_gateway.aws_api_gateway_rest_api.id
  resource_id   = aws_api_gateway_resource.v1_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_v1_endpoint_integration" {
  rest_api_id = module.rw_api_misc_api_gateway.aws_api_gateway_rest_api.id
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
  rest_api_id = module.rw_api_misc_api_gateway.aws_api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.v1_resource.id
  http_method = aws_api_gateway_method.get_v1_endpoint_method.http_method
  status_code = 200
}

resource "aws_api_gateway_integration_response" "get_v1_endpoint_integration_response" {
  rest_api_id = module.rw_api_misc_api_gateway.aws_api_gateway_rest_api.id
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