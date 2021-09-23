resource "kubernetes_service" "fw_contextual_layers_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  metadata {
    name      = "fw-contextual-layers"
    namespace = "fw"
  }
  spec {
    selector = {
      name = "fw-contextual-layers"
    }
    port {
      port        = 30528
      node_port   = 30528
      target_port = 3025
    }

    type = "NodePort"
  }
}

locals {
  api_gateway_target_url = var.connection_type == "VPC_LINK" ? data.aws_lb.load_balancer[0].dns_name : var.target_url
}

data "aws_lb" "load_balancer" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "fw_contextual_layers_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30528
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fw_contextual_layers_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "fw_contextual_layers_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  name        = "fw-contextual-layers-lb-tg"
  port        = 30528
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_fw_contextual_layers" {
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.fw_contextual_layers_lb_target_group[0].arn
}

// /v1/contextual-layer
module "v1_contextual_layer_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "contextual-layer"
}

// /v1/contextual-layer/{proxy+}
module "v1_contextual_layer_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_contextual_layer_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "fw_contextual_layers_get_v1_contextual_layer" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_contextual_layer_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30528/api/v1/contextual-layer"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "fw_contextual_layers_post_v1_contextual_layer" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_contextual_layer_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30528/api/v1/contextual-layer"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "fw_contextual_layers_any_v1_contextual_layer_proxy" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_contextual_layer_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30528/api/v1/contextual-layer/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}
