resource "kubernetes_service" "forest_change_service" {
  metadata {
    name = "forest-change"
    namespace = "gfw"
  }
  spec {
    selector = {
      name = "forest-change"
    }
    port {
      port        = 30524
      node_port   = 30524
      target_port = 62000
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "forest_change_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30524
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.forest_change_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "forest_change_lb_target_group" {
  name        = "forest-change-lb-tg"
  port        = 30524
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_forest_change" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.forest_change_lb_target_group.arn
}

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v1/terrai-alerts
resource "aws_api_gateway_resource" "v1_terrai_alerts_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "terrai-alerts"
}

// /v1/terrai-alerts/admin
resource "aws_api_gateway_resource" "v1_terrai_alerts_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_terrai_alerts_resource.id
  path_part   = "admin"
}

// /v1/terrai-alerts/admin/{isoCode}
resource "aws_api_gateway_resource" "v1_terrai_alerts_admin_iso_code_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_terrai_alerts_admin_resource.id
  path_part   = "{isoCode}"
}

// /v1/terrai-alerts/admin/{isoCode}/{adminId}
resource "aws_api_gateway_resource" "v1_terrai_alerts_admin_iso_code_admin_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_terrai_alerts_admin_iso_code_resource.id
  path_part   = "{adminId}"
}

// /v1/terrai-alerts/admin/{isoCode}/{adminId}/{distId}
resource "aws_api_gateway_resource" "v1_terrai_alerts_admin_iso_code_admin_id_dist_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_terrai_alerts_admin_iso_code_admin_id_resource.id
  path_part   = "{distId}"
}

// /v1/terrai-alerts/use
resource "aws_api_gateway_resource" "v1_terrai_alerts_use_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_terrai_alerts_resource.id
  path_part   = "use"
}

// /v1/terrai-alerts/use/{useType}
resource "aws_api_gateway_resource" "v1_terrai_alerts_use_type_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_terrai_alerts_use_resource.id
  path_part   = "{useType}"
}

// /v1/terrai-alerts/use/{useType}/{useId}
resource "aws_api_gateway_resource" "v1_terrai_alerts_use_type_use_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_terrai_alerts_use_type_resource.id
  path_part   = "{useId}"
}

// /v1/terrai-alerts/wdpa
resource "aws_api_gateway_resource" "v1_terrai_alerts_wdpa_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_terrai_alerts_resource.id
  path_part   = "wdpa"
}

// /v1/terrai-alerts/wdpa/{wdpaId}
resource "aws_api_gateway_resource" "v1_terrai_alerts_wdpa_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_terrai_alerts_wdpa_resource.id
  path_part   = "{wdpaId}"
}

// /v1/terrai-alerts/date-range
resource "aws_api_gateway_resource" "v1_terrai_alerts_date_range_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_terrai_alerts_resource.id
  path_part   = "date-range"
}

// /v1/terrai-alerts/latest
resource "aws_api_gateway_resource" "v1_terrai_alerts_latest_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_terrai_alerts_resource.id
  path_part   = "latest"
}

module "forest_change_get_v1_terrai_alerts" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_terrai_alerts_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30524/api/v2/ms/terrai-alerts"
  vpc_link     = var.vpc_link
}

module "forest_change_post_v1_terrai_alerts" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_terrai_alerts_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30524/api/v2/ms/terrai-alerts"
  vpc_link     = var.vpc_link
}

module "forest_change_get_v1_terrai_alerts_admin_iso_code" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_terrai_alerts_admin_iso_code_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30524/api/v2/ms/terrai-alerts/admin/{isoCode}"
  vpc_link     = var.vpc_link
}

module "forest_change_get_v1_terrai_alerts_admin_iso_code_admin_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_terrai_alerts_admin_iso_code_admin_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30524/api/v2/ms/terrai-alerts/admin/{isoCode}/{adminId}"
  vpc_link     = var.vpc_link
}

module "forest_change_get_v1_terrai_alerts_admin_iso_code_admin_dist_id_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_terrai_alerts_admin_iso_code_admin_id_dist_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30524/api/v2/ms/terrai-alerts/admin/{isoCode}/{adminId}/{distId}"
  vpc_link     = var.vpc_link
}

module "forest_change_get_v1_terrai_alerts_use_type_use_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_terrai_alerts_use_type_use_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30524/api/v2/ms/terrai-alerts/use/{useType}/{useId}"
  vpc_link     = var.vpc_link
}

module "forest_change_get_v1_terrai_alerts_wdpa_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_terrai_alerts_wdpa_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30524/api/v2/ms/terrai-alerts/wdpa/{wdpaId}"
  vpc_link     = var.vpc_link
}

module "forest_change_get_v1_terrai_alerts_date_range" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_terrai_alerts_date_range_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30524/api/v2/ms/terrai-alerts/date-range"
  vpc_link     = var.vpc_link
}

module "forest_change_get_v1_terrai_alerts_latest" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_terrai_alerts_latest_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30524/api/v2/ms/terrai-alerts/latest"
  vpc_link     = var.vpc_link
}