resource "kubernetes_service" "gee_tiles_service" {
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

data "aws_lb" "load_balancer" {
  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "gee_tiles_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30531
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gee_tiles_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "gee_tiles_lb_target_group" {
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
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.gee_tiles_lb_target_group.arn
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
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.gee_tiles_layer_id_tile_gee_proxy_resource.aws_api_gateway_resource
  method                      = "ANY"
  uri                         = "http://${data.aws_lb.load_balancer.dns_name}:30531/api/v1/layer/{layerId}/tile/gee/{proxy}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["layerId"]
}

module "gee_tiles_any_gee_layer_gee_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.gee_layer_gee_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30531/api/v1/layer/gee/{proxy}"
  vpc_link     = var.vpc_link
}