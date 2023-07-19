resource "kubernetes_service" "high_res_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  metadata {
    name      = "high-res"
    namespace = "gfw"
  }
  spec {
    selector = {
      name = "high-res"
    }
    port {
      port        = 30544
      node_port   = 30544
      target_port = 3050
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

resource "aws_lb_listener" "high_res_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30544
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.high_res_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "high_res_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  name        = "high-res-lb-tg"
  port        = 30544
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_high_res" {
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  lb_target_group_arn    = aws_lb_target_group.high_res_lb_target_group[0].arn
}

// /v1/high-res
module "v1_high_res_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "high-res"
}

// /v1/high-res/{sensor}
module "v1_high_res_sensor_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_high_res_resource.aws_api_gateway_resource.id
  path_part   = "{sensor}"
}

module "high_res_get_v1_high_res_sensor" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_high_res_sensor_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30544/api/v1/high-res/{sensor}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = var.require_api_key
}

