resource "kubernetes_service" "gfw_ogr_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  metadata {
    name      = "gfw-ogr"
    namespace = "gfw"
  }
  spec {
    selector = {
      name = "gfw-ogr"
    }
    port {
      port        = 30536
      node_port   = 30536
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

resource "aws_lb_listener" "gfw_ogr_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30536
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gfw_ogr_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "gfw_ogr_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  name        = "gfw-ogr-lb-tg"
  port        = 30536
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_gfw_ogr" {
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.gfw_ogr_lb_target_group[0].arn
}


// /v1/ogr
module "v1_ogr_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "ogr"
}

// /v1/ogr/{proxy+}
module "v1_ogr_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_ogr_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v2/ogr
module "v2_ogr_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v2_resource.id
  path_part   = "ogr"
}

// /v2/ogr/{proxy+}
module "v2_ogr_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v2_ogr_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "gfw_ogr_any_v2_ogr_proxy" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v2_ogr_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30536/api/v2/ogr/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "gfw_ogr_any_v1_ogr_proxy" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_ogr_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30536/api/v1/ogr/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}
