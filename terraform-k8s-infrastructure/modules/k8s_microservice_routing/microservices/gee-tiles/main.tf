resource "kubernetes_service" "gee_tiles_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  metadata {
    name = "gee-tiles"

  }
  spec {
    selector = {
      name = "gee-tiles"
    }
    port {
      port        = 30531
      node_port   = 30531
      target_port = 5700
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

resource "aws_lb_listener" "gee_tiles_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30531
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gee_tiles_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "gee_tiles_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  name        = "gee-tiles-lb-tg"
  port        = 30531
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_gee_tiles" {
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  lb_target_group_arn    = aws_lb_target_group.gee_tiles_lb_target_group[0].arn
}

// /v1/layer/{layerId}/tile
module "gee_tiles_layer_id_tile_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_layer_id_resource.id
  path_part   = "tile"
}

// /v1/layer/{layerId}/tile/gee
module "gee_tiles_layer_id_tile_gee_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.gee_tiles_layer_id_tile_resource.aws_api_gateway_resource.id
  path_part   = "gee"
}

// /v1/layer/{layerId}/tile/gee/{proxy+}
module "gee_tiles_layer_id_tile_gee_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.gee_tiles_layer_id_tile_gee_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/layer/gee
module "gee_layer_gee_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_layer_resource.id
  path_part   = "gee"
}

// /v1/layer/gee/{proxy+}
module "gee_layer_gee_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.gee_layer_gee_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "gee_tiles_any_layer_id_tile_gee_proxy" {
  source                      = "../../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.gee_tiles_layer_id_tile_gee_proxy_resource.aws_api_gateway_resource
  method                      = "ANY"
  uri                         = "http://${local.api_gateway_target_url}:30531/api/v1/layer/{layerId}/tile/gee/{proxy}"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["layerId"]
}

module "gee_tiles_any_gee_layer_gee_proxy" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.gee_layer_gee_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30531/api/v1/layer/gee/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}
