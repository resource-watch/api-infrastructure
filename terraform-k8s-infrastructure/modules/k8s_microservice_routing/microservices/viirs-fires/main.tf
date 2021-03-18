resource "kubernetes_service" "viirs_fires_service" {
  metadata {
    name      = "viirs-fires"
    namespace = "gfw"

  }
  spec {
    selector = {
      name = "viirs-fires"
    }
    port {
      port        = 30564
      node_port   = 30564
      target_port = 3600
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "viirs_fires_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30564
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.viirs_fires_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "viirs_fires_lb_target_group" {
  name        = "viirs-fires-lb-tg"
  port        = 30564
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_viirs_fires" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.viirs_fires_lb_target_group.arn
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

resource "aws_api_gateway_resource" "viirs_fires_v2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v2_resource.id
  path_part   = "viirs-active-fires"
}

resource "aws_api_gateway_resource" "viirs_latest_v2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_v2_resource.id
  path_part   = "latest"
}

# Access by GADM levels
resource "aws_api_gateway_resource" "viirs_fires_admin_v2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_v2_resource.id
  path_part   = "admin"
}

resource "aws_api_gateway_resource" "viirs_fires_by_iso_v2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_admin_v2_resource.id
  path_part   = "{iso}"
}

resource "aws_api_gateway_resource" "viirs_fires_by_id1_v2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_by_iso_v2_resource.id
  path_part   = "{id1}"
}

resource "aws_api_gateway_resource" "viirs_fires_by_id2_v2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_by_id1_v2_resource.id
  path_part   = "{id2}"
}

# Access by area id
resource "aws_api_gateway_resource" "viirs_fires_use_v2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_v2_resource.id
  path_part   = "use"
}

resource "aws_api_gateway_resource" "viirs_fires_use_by_name_v2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_use_v2_resource.id
  path_part   = "{name}"
}

resource "aws_api_gateway_resource" "viirs_fires_use_by_id_v2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_use_by_name_v2_resource.id
  path_part   = "{id}"
}

# Access Protected Areas by id
resource "aws_api_gateway_resource" "viirs_fires_wdpa_v2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_v2_resource.id
  path_part   = "wdpa"
}

resource "aws_api_gateway_resource" "viirs_fires_wdpa_by_id_v2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_wdpa_v2_resource.id
  path_part   = "{id}"
}

# v1 resources
resource "aws_api_gateway_resource" "viirs_fires_v1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "viirs-active-fires"
}

resource "aws_api_gateway_resource" "viirs_latest_v1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_v1_resource.id
  path_part   = "latest"
}

# Access by GADM levels
resource "aws_api_gateway_resource" "viirs_fires_admin_v1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_v1_resource.id
  path_part   = "admin"
}

resource "aws_api_gateway_resource" "viirs_fires_by_iso_v1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_admin_v1_resource.id
  path_part   = "{iso}"
}

resource "aws_api_gateway_resource" "viirs_fires_by_id1_v1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_by_iso_v1_resource.id
  path_part   = "{id1}"
}

resource "aws_api_gateway_resource" "viirs_fires_by_id2_v1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_by_id1_v1_resource.id
  path_part   = "{id2}"
}

# Access by area id
resource "aws_api_gateway_resource" "viirs_fires_use_v1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_v1_resource.id
  path_part   = "use"
}

resource "aws_api_gateway_resource" "viirs_fires_use_by_name_v1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_use_v1_resource.id
  path_part   = "{name}"
}

resource "aws_api_gateway_resource" "viirs_fires_use_by_id_v1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_use_by_name_v1_resource.id
  path_part   = "{id}"
}

# Access Protected Areas by id
resource "aws_api_gateway_resource" "viirs_fires_wdpa_v1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_v1_resource.id
  path_part   = "wdpa"
}

resource "aws_api_gateway_resource" "viirs_fires_wdpa_by_id_v1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_wdpa_v1_resource.id
  path_part   = "{id}"
}

# Modules
module "viirs_fires_v2_get_by_iso" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_fires_by_iso_v2_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30564/api/v2/viirs-active-fires/admin/{iso}"
  vpc_link     = var.vpc_link
}

module "viirs_fires_v2_get_by_id1" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.viirs_fires_by_id1_v2_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30564/api/v2/viirs-active-fires/admin/{iso}/{id1}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["iso"]
}

module "viirs_fires_v2_get_by_id2" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.viirs_fires_by_id2_v2_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30564/api/v2/viirs-active-fires/admin/{iso}/{id1}/{id2}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["iso", "id1"]
}

module "viirs_fires_v2_get_by_area" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.viirs_fires_use_by_id_v2_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30564/api/v2/viirs-active-fires/use/{name}/{id}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["name"]
}

module "viirs_fires_v2_get_wdpa" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_fires_wdpa_by_id_v2_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30564/api/v2/viirs-active-fires/wdpa/{id}"
  vpc_link     = var.vpc_link
}

module "viirs_fires_v2_get_active_fires" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_fires_v2_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30564/api/v2/viirs-active-fires"
  vpc_link     = var.vpc_link
}

module "viirs_fires_v2_set_active_fires" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_fires_v2_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30564/api/v2/viirs-active-fires"
  vpc_link     = var.vpc_link
}

module "viirs_fires_v2_get_latest_fires" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_latest_v2_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30564/api/v2/viirs-active-fires/latest"
  vpc_link     = var.vpc_link
}

# v1 modules
module "viirs_fires_v1_get_by_iso" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_fires_by_iso_v1_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30564/api/v2/viirs-active-fires/admin/{iso}"
  vpc_link     = var.vpc_link
}

module "viirs_fires_v1_get_by_id1" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.viirs_fires_by_id1_v1_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30564/api/v2/viirs-active-fires/admin/{iso}/{id1}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["iso"]
}

module "viirs_fires_v1_get_by_id2" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.viirs_fires_by_id2_v1_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30564/api/v2/viirs-active-fires/admin/{iso}/{id1}/{id2}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["iso", "id1"]
}

module "viirs_fires_v1_get_by_area" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.viirs_fires_use_by_id_v1_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30564/api/v2/viirs-active-fires/use/{name}/{id}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["name"]
}

module "viirs_fires_v1_get_wdpa" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_fires_wdpa_by_id_v1_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30564/api/v2/viirs-active-fires/wdpa/{id}"
  vpc_link     = var.vpc_link
}

module "viirs_fires_v1_get_active_fires" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_fires_v1_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30564/api/v2/viirs-active-fires"
  vpc_link     = var.vpc_link
}

module "viirs_fires_v1_set_active_fires" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_fires_v1_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30564/api/v2/viirs-active-fires"
  vpc_link     = var.vpc_link
}

module "viirs_fires_v1_get_latest_fires" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_latest_v1_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30564/api/v2/viirs-active-fires/latest"
  vpc_link     = var.vpc_link
}

