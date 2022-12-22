resource "kubernetes_service" "true_color_tiles_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  metadata {
    name      = "true-color-tiles"
    namespace = "gfw"
  }
  spec {
    selector = {
      name = "true-color-tiles"
    }
    port {
      port        = 30563
      node_port   = 30563
      target_port = 3547
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

resource "aws_lb_listener" "true_color_tiles_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30563
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.true_color_tiles_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "true_color_tiles_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  name        = "true-color-tiles-lb-tg"
  port        = 30563
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_true_color_tiles" {
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  lb_target_group_arn   = aws_lb_target_group.true_color_tiles_lb_target_group[0].arn
}

// /v1/true-color-tiles
module "v1_true_color_tiles_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "true-color-tiles"
}

// /v1/true-color-tiles/{proxy+}
module "v1_true_color_tiles_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_true_color_tiles_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "true_color_tiles_get_v1_true_color_tiles_proxy" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_true_color_tiles_proxy_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30563/api/v1/true-color-tiles/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

