resource "kubernetes_service" "gfw_forma_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  metadata {
    name      = "gfw-forma"
    namespace = "gfw"
  }
  spec {
    selector = {
      name = "gfw-forma"
    }
    port {
      port        = 30534
      node_port   = 30534
      target_port = 3600
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

resource "aws_lb_listener" "gfw_forma_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30534
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gfw_forma_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "gfw_forma_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  name        = "gfw-forma-lb-tg"
  port        = 30534
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_gfw_forma" {
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  lb_target_group_arn    = aws_lb_target_group.gfw_forma_lb_target_group[0].arn
}

// /v1/forma-alerts
module "v1_forma_alerts_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "forma-alerts"
}

// /v1/forma-alerts/{proxy+}
module "v1_forma_alerts_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_forma_alerts_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "gfw_forma_get_v1_forma_alerts" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_forma_alerts_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30534/api/v1/forma-alerts"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "gfw_forma_post_v1_forma_alerts" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_forma_alerts_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30534/api/v1/forma-alerts"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "gfw_forma_any_v1_forma_alerts_proxy" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_forma_alerts_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30534/api/v1/forma-alerts/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}
