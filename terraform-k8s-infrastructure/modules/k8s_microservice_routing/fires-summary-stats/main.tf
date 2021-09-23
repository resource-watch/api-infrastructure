resource "kubernetes_service" "fires_summary_stats_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  metadata {
    name = "fires-summary-stats"

  }
  spec {
    selector = {
      name = "fires-summary-stats"
    }
    port {
      port        = 30523
      node_port   = 30523
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

resource "aws_lb_listener" "fires_summary_stats_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30523
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fires_summary_stats_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "fires_summary_stats_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  name        = "fires-summary-stats-lb-tg"
  port        = 30523
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_fires_summary_stats" {
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.fires_summary_stats_lb_target_group[0].arn
}

// /v1/fire-alerts
module "fire_alerts_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "fire-alerts"
}

// /v1/fire-alerts/{proxy+}
module "fire_alerts_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.fire_alerts_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/glad-alerts
module "glad_alerts_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "glad-alerts"
}

// /v1/glad-alerts/summary-stats
module "glad_alerts_summary_stats_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.glad_alerts_resource.aws_api_gateway_resource.id
  path_part   = "summary-stats"
}

// /v1/glad-alerts/summary-stats/{proxy+}
module "glad_alerts_summary_stats_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.glad_alerts_summary_stats_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "fires_summary_stats_any_fire_alerts_proxy" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.fire_alerts_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30523/api/v1/fire-alerts/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "fires_summary_stats_any_glad_alerts_summary_stats_proxy" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.glad_alerts_summary_stats_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30523/api/v1/glad-alerts/summary-stats/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

