resource "kubernetes_service" "forest_watcher_api_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  metadata {
    name      = "forest-watcher-api"
    namespace = "fw"
  }
  spec {
    selector = {
      name = "forest-watcher-api"
    }
    port {
      port        = 30525
      node_port   = 30525
      target_port = 4400
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

resource "aws_lb_listener" "forest_watcher_api_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30525
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.forest_watcher_api_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "forest_watcher_api_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  name        = "forest-watcher-api-lb-tg"
  port        = 30525
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_forest_watcher_api" {
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.forest_watcher_api_lb_target_group[0].arn
}

// /v1/forest-watcher
module "v1_forest_watcher_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "forest-watcher"
}

// /v1/forest-watcher/area
module "v1_forest_watcher_area_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_forest_watcher_resource.aws_api_gateway_resource.id
  path_part   = "area"
}

module "forest_watcher_api_get_v1_forest_watcher_area_resource" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_forest_watcher_area_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30525/api/v1/forest-watcher/area"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "forest_watcher_api_post_v1_forest_watcher_area_resource" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_forest_watcher_area_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30525/api/v1/forest-watcher/area"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}
