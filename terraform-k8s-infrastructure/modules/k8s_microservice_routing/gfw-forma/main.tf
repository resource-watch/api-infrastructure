resource "kubernetes_service" "gfw_forma_service" {
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

resource "aws_lb_listener" "gfw_forma_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30534
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gfw_forma_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "gfw_forma_lb_target_group" {
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
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.gfw_forma_lb_target_group.arn
}

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v1/forma-alerts
resource "aws_api_gateway_resource" "v1_terrai_alerts_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "forma-alerts"
}

// /v1/forma-alerts/admin
resource "aws_api_gateway_resource" "v1_terrai_alerts_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_terrai_alerts_resource.id
  path_part   = "admin"
}

// /v1/forma-alerts/admin/{iso}
resource "aws_api_gateway_resource" "v1_terrai_alerts_admin_iso_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_terrai_alerts_admin_resource.id
  path_part   = "{iso}"
}

// /v1/forma-alerts/admin/{iso}/{id}
resource "aws_api_gateway_resource" "v1_terrai_alerts_admin_iso_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_terrai_alerts_admin_iso_resource.id
  path_part   = "{id}"
}

// /v1/forma-alerts/use
resource "aws_api_gateway_resource" "v1_terrai_alerts_use_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_terrai_alerts_resource.id
  path_part   = "use"
}

// /v1/forma-alerts/use/{name}
resource "aws_api_gateway_resource" "v1_terrai_alerts_use_name_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_terrai_alerts_use_resource.id
  path_part   = "{name}"
}

// /v1/forma-alerts/use/{name}/{id}
resource "aws_api_gateway_resource" "v1_terrai_alerts_use_name_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_terrai_alerts_use_name_resource.id
  path_part   = "{id}"
}

// /v1/forma-alerts/wdpa
resource "aws_api_gateway_resource" "v1_terrai_alerts_wdpa_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_terrai_alerts_resource.id
  path_part   = "wdpa"
}

// /v1/forma-alerts/wdpa/{id}
resource "aws_api_gateway_resource" "v1_terrai_alerts_wdpa_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_terrai_alerts_wdpa_resource.id
  path_part   = "{id}"
}

// /v1/forma-alerts/latest
resource "aws_api_gateway_resource" "v1_terrai_alerts_latest_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_terrai_alerts_resource.id
  path_part   = "latest"
}

module "gfw_forma_get_v1_terrai_alerts_admin_iso" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_terrai_alerts_admin_iso_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30534/api/v1/forma-alerts/admin/{iso}"
  vpc_link     = var.vpc_link
}

module "gfw_forma_get_v1_terrai_alerts_admin_iso_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_terrai_alerts_admin_iso_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30534/api/v1/forma-alerts/admin/{iso}/{id}"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["iso"]
}

module "gfw_forma_get_v1_terrai_alerts_use_name_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_terrai_alerts_use_name_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30534/api/v1/forma-alerts/use/{name}/{id}"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["name"]
}

module "gfw_forma_get_v1_terrai_alerts_wdpa_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_terrai_alerts_wdpa_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30534/api/v1/forma-alerts/wdpa/{id}"
  vpc_link     = var.vpc_link
}

module "gfw_forma_get_v1_terrai_alerts" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_terrai_alerts_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30534/api/v1/forma-alerts"
  vpc_link     = var.vpc_link
}

module "gfw_forma_post_v1_terrai_alerts" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_terrai_alerts_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30534/api/v1/forma-alerts"
  vpc_link     = var.vpc_link
}

module "gfw_forma_get_v1_terrai_alerts_latest" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_terrai_alerts_latest_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30534/api/v1/forma-alerts/latest"
  vpc_link     = var.vpc_link
}