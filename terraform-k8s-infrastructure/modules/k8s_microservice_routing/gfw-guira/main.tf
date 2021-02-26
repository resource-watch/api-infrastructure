resource "kubernetes_service" "gfw_guira_service" {
  metadata {
    name = "gfw-guira"
    namespace = "gfw"
  }
  spec {
    selector = {
      name = "gfw-guira"
    }
    port {
      port        = 30535
      node_port   = 30535
      target_port = 3600
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "gfw_guira_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30535
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gfw_guira_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "gfw_guira_lb_target_group" {
  name        = "gfw-guira-lb-tg"
  port        = 30535
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_gfw_guira" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.gfw_guira_lb_target_group.arn
}

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v2
data "aws_api_gateway_resource" "v2_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v2"
}

// /v1/guira-loss
resource "aws_api_gateway_resource" "v1_guira_loss_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "guira-loss"
}

// /v1/guira-loss/admin
resource "aws_api_gateway_resource" "v1_guira_loss_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_guira_loss_resource.id
  path_part   = "admin"
}

// /v1/guira-loss/admin/{iso}
resource "aws_api_gateway_resource" "v1_guira_loss_admin_iso_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_guira_loss_admin_resource.id
  path_part   = "{iso}"
}

// /v1/guira-loss/admin/{iso}/{id1}
resource "aws_api_gateway_resource" "v1_guira_loss_admin_iso_id_1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_guira_loss_admin_iso_resource.id
  path_part   = "{id1}"
}

// /v1/guira-loss/use
resource "aws_api_gateway_resource" "v1_guira_loss_use_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_guira_loss_resource.id
  path_part   = "use"
}

// /v1/guira-loss/use/{name}
resource "aws_api_gateway_resource" "v1_guira_loss_use_name_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_guira_loss_use_resource.id
  path_part   = "{name}"
}

// /v1/guira-loss/use/{name}/{id}
resource "aws_api_gateway_resource" "v1_guira_loss_use_name_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_guira_loss_use_name_resource.id
  path_part   = "{id}"
}

// /v1/guira-loss/wdpa
resource "aws_api_gateway_resource" "v1_guira_loss_wdpa_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_guira_loss_resource.id
  path_part   = "wdpa"
}

// /v1/guira-loss/wdpa/{id}
resource "aws_api_gateway_resource" "v1_guira_loss_wdpa_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_guira_loss_wdpa_resource.id
  path_part   = "{id}"
}

// /v1/guira-loss/latest
resource "aws_api_gateway_resource" "v1_guira_loss_latest_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_guira_loss_resource.id
  path_part   = "latest"
}

// /v2/guira-loss
resource "aws_api_gateway_resource" "v2_guira_loss_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v2_resource.id
  path_part   = "guira-loss"
}

// /v2/guira-loss/admin
resource "aws_api_gateway_resource" "v2_guira_loss_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_guira_loss_resource.id
  path_part   = "admin"
}

// /v2/guira-loss/admin/{iso}
resource "aws_api_gateway_resource" "v2_guira_loss_admin_iso_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_guira_loss_admin_resource.id
  path_part   = "{iso}"
}

// /v2/guira-loss/admin/{iso}/{id1}
resource "aws_api_gateway_resource" "v2_guira_loss_admin_iso_id_1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_guira_loss_admin_iso_resource.id
  path_part   = "{id1}"
}

// /v2/guira-loss/admin/{iso}/{id1}/{id2}
resource "aws_api_gateway_resource" "v2_guira_loss_admin_iso_id_1_id_2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_guira_loss_admin_iso_id_1_resource.id
  path_part   = "{id2}"
}

// /v2/guira-loss/use
resource "aws_api_gateway_resource" "v2_guira_loss_use_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_guira_loss_resource.id
  path_part   = "use"
}

// /v2/guira-loss/use/{name}
resource "aws_api_gateway_resource" "v2_guira_loss_use_name_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_guira_loss_use_resource.id
  path_part   = "{name}"
}

// /v2/guira-loss/use/{name}/{id}
resource "aws_api_gateway_resource" "v2_guira_loss_use_name_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_guira_loss_use_name_resource.id
  path_part   = "{id}"
}

// /v2/guira-loss/wdpa
resource "aws_api_gateway_resource" "v2_guira_loss_wdpa_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_guira_loss_resource.id
  path_part   = "wdpa"
}

// /v2/guira-loss/wdpa/{id}
resource "aws_api_gateway_resource" "v2_guira_loss_wdpa_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_guira_loss_wdpa_resource.id
  path_part   = "{id}"
}

// /v2/guira-loss/latest
resource "aws_api_gateway_resource" "v2_guira_loss_latest_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_guira_loss_resource.id
  path_part   = "latest"
}

module "gfw_guira_get_v2_guira_loss_admin_iso" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_guira_loss_admin_iso_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30535/api/v2/guira-loss/admin/{iso}"
  vpc_link     = var.vpc_link
}

module "gfw_guira_get_v2_guira_loss_admin_iso_id_1" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_guira_loss_admin_iso_id_1_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30535/api/v2/guira-loss/admin/{iso}/{id1}"
  vpc_link     = var.vpc_link
}

module "gfw_guira_get_v2_guira_loss_admin_iso_id_1_id_2" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_guira_loss_admin_iso_id_1_id_2_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30535/api/v2/guira-loss/admin/{iso}/{id1}/{id2}"
  vpc_link     = var.vpc_link
}

module "gfw_guira_get_v2_guira_loss_use_name_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_guira_loss_use_name_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30535/api/v2/guira-loss/use/{name}/{id}"
  vpc_link     = var.vpc_link
}

module "gfw_guira_get_v2_guira_loss_wdpa_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_guira_loss_wdpa_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30535/api/v2/guira-loss/wdpa/{id}"
  vpc_link     = var.vpc_link
}

module "gfw_guira_get_v2_guira_loss" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_guira_loss_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30535/api/v2/guira-loss"
  vpc_link     = var.vpc_link
}

module "gfw_guira_get_v2_guira_loss_latest" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_guira_loss_latest_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30535/api/v2/guira-loss/latest"
  vpc_link     = var.vpc_link
}

module "gfw_guira_post_v2_guira_loss" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_guira_loss_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30535/api/v2/guira-loss"
  vpc_link     = var.vpc_link
}

module "gfw_guira_get_v1_guira_loss_admin_iso" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_guira_loss_admin_iso_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30535/api/v1/guira-loss/admin/{iso}"
  vpc_link     = var.vpc_link
}

module "gfw_guira_get_v1_guira_loss_admin_iso_id_1" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_guira_loss_admin_iso_id_1_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30535/api/v1/guira-loss/admin/{iso}/{id1}"
  vpc_link     = var.vpc_link
}

module "gfw_guira_get_v1_guira_loss_use_name_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_guira_loss_use_name_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30535/api/v1/guira-loss/use/{name}/{id}"
  vpc_link     = var.vpc_link
}

module "gfw_guira_get_v1_guira_loss_wdpa_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_guira_loss_wdpa_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30535/api/v1/guira-loss/wdpa/{id}"
  vpc_link     = var.vpc_link
}

module "gfw_guira_get_v1_guira_loss" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_guira_loss_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30535/api/v1/guira-loss"
  vpc_link     = var.vpc_link
}

module "gfw_guira_post_v1_guira_loss" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_guira_loss_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30535/api/v1/guira-loss"
  vpc_link     = var.vpc_link
}

module "gfw_guira_get_v1_guira_loss_latest" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_guira_loss_latest_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30535/api/v1/guira-loss/latest"
  vpc_link     = var.vpc_link
}