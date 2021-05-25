resource "kubernetes_service" "glad_analysis_tiled_service" {
  metadata {
    name      = "glad-analysis-tiled"
    namespace = "gfw"
  }
  spec {
    selector = {
      name = "glad-analysis-athena"
    }
    port {
      port        = 30541
      node_port   = 30541
      target_port = 5702
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  arn  = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "glad_analysis_tiled_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30541
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.glad_analysis_tiled_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "glad_analysis_tiled_lb_target_group" {
  name        = "glad-analysis-tiled-lb-tg"
  port        = 30541
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_glad_analysis_tiled" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.glad_analysis_tiled_lb_target_group.arn
}

// /v1/glad-alerts/admin
resource "aws_api_gateway_resource" "v1_glad_alerts_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_glad_alerts_resource.id
  path_part   = "admin"
}

// /v1/glad-alerts/admin/{proxy+}
resource "aws_api_gateway_resource" "v1_glad_alerts_admin_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_glad_alerts_admin_resource.id
  path_part   = "{proxy+}"
}

// /v1/glad-alerts/download
resource "aws_api_gateway_resource" "v1_glad_alerts_download_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_glad_alerts_resource.id
  path_part   = "download"
}

// /v1/glad-alerts/latest
resource "aws_api_gateway_resource" "v1_glad_alerts_latest_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_glad_alerts_resource.id
  path_part   = "latest"
}

// /v1/glad-alerts/wdpa
resource "aws_api_gateway_resource" "v1_glad_alerts_wdpa_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_glad_alerts_resource.id
  path_part   = "wdpa"
}

// /v1/glad-alerts/wdpa/{proxy+}
resource "aws_api_gateway_resource" "v1_glad_alerts_wdpa_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_glad_alerts_wdpa_resource.id
  path_part   = "{proxy+}"
}

// /v1/glad-alerts/use
resource "aws_api_gateway_resource" "v1_glad_alerts_use_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_glad_alerts_resource.id
  path_part   = "use"
}

// /v1/glad-alerts/use/{proxy+}
resource "aws_api_gateway_resource" "v1_glad_alerts_use_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_glad_alerts_use_resource.id
  path_part   = "{proxy+}"
}

module "glad_analysis_tiled_any_v1_glad_alerts_admin_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_glad_alerts_admin_proxy_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30541/api/v1/glad-alerts-athena/admin/{proxy}"
  vpc_link     = var.vpc_link
}

module "glad_analysis_tiled_get_v1_glad_alerts_download" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_glad_alerts_download_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30541/api/v1/glad-alerts-athena/download"
  vpc_link     = var.vpc_link
}

module "glad_analysis_tiled_post_v1_glad_alerts_download" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_glad_alerts_download_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30541/api/v1/glad-alerts-athena/download"
  vpc_link     = var.vpc_link
}

module "glad_analysis_tiled_get_v1_glad_alerts" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = var.v1_glad_alerts_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30541/api/v1/glad-alerts-athena"
  vpc_link     = var.vpc_link
}

module "glad_analysis_tiled_post_v1_glad_alerts" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = var.v1_glad_alerts_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30541/api/v1/glad-alerts-athena"
  vpc_link     = var.vpc_link
}

module "glad_analysis_tiled_get_v1_glad_alerts_latest" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_glad_alerts_latest_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30541/api/v1/glad-alerts-athena/latest"
  vpc_link     = var.vpc_link
}

module "glad_analysis_tiled_any_v1_glad_alerts_wdpa_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_glad_alerts_wdpa_proxy_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30541/api/v1/glad-alerts-athena/wdpa/{proxy}"
  vpc_link     = var.vpc_link
}

module "glad_analysis_tiled_any_v1_glad_alerts_use_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_glad_alerts_use_proxy_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30541/api/v1/glad-alerts-athena/use/{proxy}"
  vpc_link     = var.vpc_link
}

