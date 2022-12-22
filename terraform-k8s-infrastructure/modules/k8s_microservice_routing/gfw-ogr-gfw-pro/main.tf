resource "kubernetes_service" "gfw_ogr_gfw_pro_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  metadata {
    name      = "gfw-ogr-gfw-pro"
    namespace = "default"
  }
  spec {
    selector = {
      name = "gfw-ogr-gfw-pro"
    }
    port {
      port        = 30568
      node_port   = 30568
      target_port = 3200
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

resource "aws_lb_listener" "gfw_ogr_gfw_pro_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30568
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gfw_ogr_gfw_pro_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "gfw_ogr_gfw_pro_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  name        = "gfw-ogr-gfw-pro-lb-tg"
  port        = 30568
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_gfw_ogr_gfw_pro" {
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  lb_target_group_arn   = aws_lb_target_group.gfw_ogr_gfw_pro_lb_target_group[0].arn
}

// /v1/gfw-pro
module "v1_gfw_pro_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "gfw-pro"
}

// /v1/gfw-pro/{proxy+}
module "v1_gfw_pro_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_gfw_pro_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "gfw_ogr_any_v1_gfw_pro_proxy" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_gfw_pro_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30568/api/v1/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}
