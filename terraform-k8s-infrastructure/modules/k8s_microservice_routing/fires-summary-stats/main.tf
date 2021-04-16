resource "kubernetes_service" "fires_summary_stats_service" {
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

resource "aws_lb_listener" "fires_summary_stats_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30523
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fires_summary_stats_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "fires_summary_stats_lb_target_group" {
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
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.fires_summary_stats_lb_target_group.arn
}

// /v1/fire-alerts
resource "aws_api_gateway_resource" "fire_alerts_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "fire-alerts"
}

// /v1/fire-alerts/{proxy+}
resource "aws_api_gateway_resource" "fire_alerts_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.fire_alerts_resource.id
  path_part   = "{proxy+}"
}

// /v1/glad-alerts
resource "aws_api_gateway_resource" "glad_alerts_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "glad-alerts"
}

// /v1/glad-alerts/summary-stats
resource "aws_api_gateway_resource" "glad_alerts_summary_stats_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.glad_alerts_resource.id
  path_part   = "summary-stats"
}

// /v1/glad-alerts/summary-stats/{proxy+}
resource "aws_api_gateway_resource" "glad_alerts_summary_stats_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.glad_alerts_summary_stats_resource.id
  path_part   = "{proxy+}"
}

module "fires_summary_stats_any_fire_alerts_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.fire_alerts_proxy_resource
  method       = "ANY"
  uri          = "http://${var.load_balancer.dns_name}:30523/api/v1/fire-alerts/{proxy}"
  vpc_link     = var.vpc_link
}

module "fires_summary_stats_any_glad_alerts_summary_stats_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.glad_alerts_summary_stats_proxy_resource
  method       = "ANY"
  uri          = "http://${var.load_balancer.dns_name}:30523/api/v1/glad-alerts/summary-stats/{proxy}"
  vpc_link     = var.vpc_link
}

