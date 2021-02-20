resource "kubernetes_service" "fires_summary_stats_service" {
  metadata {
    name = "fires-summary-stats"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                 = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=fires-summary-stats"
    }
  }
  spec {
    selector = {
      name = "fires-summary-stats"
    }
    port {
      port        = 80
      target_port = 5700
    }

    type = "LoadBalancer"
  }
}

data "aws_lb" "fires_summary_stats_lb" {
  name = split("-", kubernetes_service.fires_summary_stats_service.status.0.load_balancer.0.ingress.0.hostname).0

  depends_on = [
    kubernetes_service.fires_summary_stats_service
  ]
}

resource "aws_api_gateway_vpc_link" "fires_summary_stats_lb_vpc_link" {
  name        = "Fires summary stats LB VPC link"
  description = "VPC link to the fires summary stats service load balancer"
  target_arns = [data.aws_lb.fires_summary_stats_lb.arn]

  lifecycle {
    create_before_destroy = true
  }
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
  uri          = "http://api.resourcewatch.org/api/v1/fire-alerts/summary-stats/{polyname}/{iso}"
  vpc_link     = aws_api_gateway_vpc_link.fires_summary_stats_lb_vpc_link
}

module "fires_summary_stats_get_fire_alerts_summary_stats_polyname_iso_adm1_code" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.fire_alerts_summary_stats_polyname_iso_adm1_code_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/fire-alerts/summary-stats/{polyname}/{iso}/{adm1Code}"
  vpc_link     = aws_api_gateway_vpc_link.fires_summary_stats_lb_vpc_link
}

module "fires_summary_stats_get_fire_alerts_summary_stats_polyname_iso_adm1_code_adm2_code" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.fire_alerts_summary_stats_polyname_iso_adm1_code_adm2_code_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/fire-alerts/summary-stats/{polyname}/{iso}/{adm1Code}/{adm2Code}"
  vpc_link     = aws_api_gateway_vpc_link.fires_summary_stats_lb_vpc_link
}

module "fires_summary_stats_get_glad_alerts_summary_stats_adm_iso" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.glad_alerts_summary_stats_admin_iso_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/glad-alerts/summary-stats/admin/{iso}"
  vpc_link     = aws_api_gateway_vpc_link.fires_summary_stats_lb_vpc_link
}

module "fires_summary_stats_get_glad_alerts_summary_stats_adm_iso_adm1_code" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.glad_alerts_summary_stats_admin_iso_adm1_code_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/glad-alerts/summary-stats/admin/{iso}/{adm1Code}"
  vpc_link     = aws_api_gateway_vpc_link.fires_summary_stats_lb_vpc_link
}

module "fires_summary_stats_get_glad_alerts_summary_stats_adm_iso_adm1_code_adm2_code" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.glad_alerts_summary_stats_admin_iso_adm1_code_adm2_code_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/glad-alerts/summary-stats/admin/{iso}/{adm1Code}/{adm2Code}"
  vpc_link     = aws_api_gateway_vpc_link.fires_summary_stats_lb_vpc_link
}
