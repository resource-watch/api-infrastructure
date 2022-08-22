resource "kubernetes_service" "rw_lp_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  metadata {
    name      = "rw-lp"
    namespace = "default"

  }
  spec {
    selector = {
      name = "rw-lp"
    }
    port {
      port        = 30559
      node_port   = 30559
      target_port = 8080
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

resource "aws_lb_listener" "rw_lp_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30559
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rw_lp_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "rw_lp_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  name        = "rw-lp-lb-tg"
  port        = 30559
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_rw_lp" {
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  lb_target_group_arn    = aws_lb_target_group.rw_lp_lb_target_group[0].arn
}

// /
data "aws_api_gateway_resource" "root_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/"
}

// /rw-lp
module "rw_lp_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.root_resource.id
  path_part   = "rw-lp"
}

// /rw-lp/{proxy+}
module "rw_lp_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.rw_lp_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "rw_lp_get_home" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = data.aws_api_gateway_resource.root_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30559/"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "rw_lp_get_rw_lp_proxy" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.rw_lp_proxy_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30559/rw-lp/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

