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

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/query"
}

// /v1/fire-alerts
resource "aws_api_gateway_resource" "fire_alerts_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "fire-alerts"
}

// /v1/fire-alerts/summary-stats
resource "aws_api_gateway_resource" "fire_alerts_summary_stats_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.fire_alerts_resource.id
  path_part   = "summary-stats"
}

// /v1/fire-alerts/summary-stats/{polyname}
resource "aws_api_gateway_resource" "fire_alerts_summary_stats_polyname_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.fire_alerts_summary_stats_resource.id
  path_part   = "{polyname}"
}

// /v1/fire-alerts/summary-stats/{polyname}/{iso}
resource "aws_api_gateway_resource" "fire_alerts_summary_stats_polyname_iso_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.fire_alerts_summary_stats_polyname_resource.id
  path_part   = "{iso}"
}

// /v1/fire-alerts/summary-stats/{polyname}/{iso}/{adm1Code}
resource "aws_api_gateway_resource" "fire_alerts_summary_stats_polyname_iso_adm1_code_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.fire_alerts_summary_stats_polyname_iso_resource.id
  path_part   = "{adm1Code}"
}

// /v1/fire-alerts/summary-stats/{polyname}/{iso}/{adm1Code}/{adm2Code}
resource "aws_api_gateway_resource" "fire_alerts_summary_stats_polyname_iso_adm1_code_adm2_code_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.fire_alerts_summary_stats_polyname_iso_adm1_code_resource.id
  path_part   = "{adm2Code}"
}

// /v1/glad-alerts
resource "aws_api_gateway_resource" "glad_alerts_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "glad-alerts"
}

// /v1/glad-alerts/summary-stats
resource "aws_api_gateway_resource" "glad_alerts_summary_stats_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.glad_alerts_resource.id
  path_part   = "summary-stats"
}

// /v1/glad-alerts/summary-stats/admin
resource "aws_api_gateway_resource" "glad_alerts_summary_stats_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.glad_alerts_summary_stats_resource.id
  path_part   = "admin"
}

// /v1/glad-alerts/summary-stats/admin/{iso]
resource "aws_api_gateway_resource" "glad_alerts_summary_stats_admin_iso_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.glad_alerts_summary_stats_admin_resource.id
  path_part   = "{iso}"
}

// /v1/glad-alerts/summary-stats/admin/{iso}/{adm1Code}
resource "aws_api_gateway_resource" "glad_alerts_summary_stats_admin_iso_adm1_code_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.glad_alerts_summary_stats_admin_iso_resource.id
  path_part   = "{adm1Code}"
}

// /v1/glad-alerts/summary-stats/admin/{iso}/{adm1Code}/{adm2Code}
resource "aws_api_gateway_resource" "glad_alerts_summary_stats_admin_iso_adm1_code_adm2_code_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.glad_alerts_summary_stats_admin_iso_adm1_code_resource.id
  path_part   = "{adm2Code}"
}

module "fires_summary_stats_get_fire_alerts_summary_stats_polyname_iso" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.fire_alerts_summary_stats_polyname_iso_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30523/api/v1/fire-alerts/summary-stats/{polyname}/{iso}"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["polyname"]
}

module "fires_summary_stats_get_fire_alerts_summary_stats_polyname_iso_adm1_code" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.fire_alerts_summary_stats_polyname_iso_adm1_code_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30523/api/v1/fire-alerts/summary-stats/{polyname}/{iso}/{adm1Code}"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["polyname", "iso"]
}

module "fires_summary_stats_get_fire_alerts_summary_stats_polyname_iso_adm1_code_adm2_code" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.fire_alerts_summary_stats_polyname_iso_adm1_code_adm2_code_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30523/api/v1/fire-alerts/summary-stats/{polyname}/{iso}/{adm1Code}/{adm2Code}"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["polyname", "iso", "adm1Code"]
}

module "fires_summary_stats_get_glad_alerts_summary_stats_adm_iso" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.glad_alerts_summary_stats_admin_iso_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30523/api/v1/glad-alerts/summary-stats/admin/{iso}"
  vpc_link     = var.vpc_link
}

module "fires_summary_stats_get_glad_alerts_summary_stats_adm_iso_adm1_code" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.glad_alerts_summary_stats_admin_iso_adm1_code_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30523/api/v1/glad-alerts/summary-stats/admin/{iso}/{adm1Code}"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["iso"]
}

module "fires_summary_stats_get_glad_alerts_summary_stats_adm_iso_adm1_code_adm2_code" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.glad_alerts_summary_stats_admin_iso_adm1_code_adm2_code_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30523/api/v1/glad-alerts/summary-stats/admin/{iso}/{adm1Code}/{adm2Code}"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["iso", "adm1Code"]
}
