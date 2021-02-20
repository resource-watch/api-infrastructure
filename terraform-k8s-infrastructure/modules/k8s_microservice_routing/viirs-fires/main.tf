
resource "kubernetes_service" "viirs_fires_service" {
  metadata {
    name      = "viirs-fires"
    namespace = "gfw"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                 = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=viirs-fires"
    }
  }
  spec {
    selector = {
      name = "viirs-fires"
    }
    port {
      port        = 80
      target_port = 3600
    }

    type = "LoadBalancer"
  }
}

data "aws_lb" "viirs_fires_lb" {
  name = split("-", kubernetes_service.viirs_fires_service.status.0.load_balancer.0.ingress.0.hostname).0

  depends_on = [
    kubernetes_service.viirs_fires_service
  ]
}

resource "aws_api_gateway_vpc_link" "viirs_fires_lb_vpc_link" {
  name        = "Viirs Fires LB VPC link"
  description = "VPC link to the viirs fires service load balancer"
  target_arns = [data.aws_lb.viirs_fires_lb.arn]

  lifecycle {
    create_before_destroy = true
  }
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
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_fires_by_iso_v2_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/viirs-active-fires/admin/{iso}"
  vpc_link     = aws_api_gateway_vpc_link.viirs_fires_lb_vpc_link
}

module "viirs_fires_v2_get_by_id1" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_fires_by_id1_v2_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/viirs-active-fires/admin/{iso}/{id1}"
  vpc_link     = aws_api_gateway_vpc_link.viirs_fires_lb_vpc_link
}

module "viirs_fires_v2_get_by_id2" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_fires_by_id2_v2_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/viirs-active-fires/admin/{iso}/{id1}/{id2}"
  vpc_link     = aws_api_gateway_vpc_link.viirs_fires_lb_vpc_link
}

module "viirs_fires_v2_get_by_area" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_fires_use_by_id_v2_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/viirs-active-fires/use/{name}/{id}"
  vpc_link     = aws_api_gateway_vpc_link.viirs_fires_lb_vpc_link
}

module "viirs_fires_v2_get_wdpa" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_fires_wdpa_by_id_v2_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/viirs-active-fires/wdpa/{id}"
  vpc_link     = aws_api_gateway_vpc_link.viirs_fires_lb_vpc_link
}

module "viirs_fires_v2_get_active_fires" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_fires_v2_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/viirs-active-fires"
  vpc_link     = aws_api_gateway_vpc_link.viirs_fires_lb_vpc_link
}

module "viirs_fires_v2_set_active_fires" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_fires_v2_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v2/viirs-active-fires"
  vpc_link     = aws_api_gateway_vpc_link.viirs_fires_lb_vpc_link
}

module "viirs_fires_v2_get_latest_fires" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_latest_v2_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/viirs-active-fires/latest"
  vpc_link     = aws_api_gateway_vpc_link.viirs_fires_lb_vpc_link
}

# v1 modules
module "viirs_fires_v1_get_by_iso" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_fires_by_iso_v1_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/viirs-active-fires/admin/{iso}"
  vpc_link     = aws_api_gateway_vpc_link.viirs_fires_lb_vpc_link
}

module "viirs_fires_v1_get_by_id1" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_fires_by_id1_v1_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/viirs-active-fires/admin/{iso}/{id1}"
  vpc_link     = aws_api_gateway_vpc_link.viirs_fires_lb_vpc_link
}

module "viirs_fires_v1_get_by_id2" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_fires_by_id2_v1_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/viirs-active-fires/admin/{iso}/{id1}/{id2}"
  vpc_link     = aws_api_gateway_vpc_link.viirs_fires_lb_vpc_link
}

module "viirs_fires_v1_get_by_area" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_fires_use_by_id_v1_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/viirs-active-fires/use/{name}/{id}"
  vpc_link     = aws_api_gateway_vpc_link.viirs_fires_lb_vpc_link
}

module "viirs_fires_v1_get_wdpa" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_fires_wdpa_by_id_v1_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/viirs-active-fires/wdpa/{id}"
  vpc_link     = aws_api_gateway_vpc_link.viirs_fires_lb_vpc_link
}

module "viirs_fires_v1_get_active_fires" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_fires_v1_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/viirs-active-fires"
  vpc_link     = aws_api_gateway_vpc_link.viirs_fires_lb_vpc_link
}

module "viirs_fires_v1_set_active_fires" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_fires_v1_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v2/viirs-active-fires"
  vpc_link     = aws_api_gateway_vpc_link.viirs_fires_lb_vpc_link
}

module "viirs_fires_v1_get_latest_fires" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.viirs_latest_v1_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/viirs-active-fires/latest"
  vpc_link     = aws_api_gateway_vpc_link.viirs_fires_lb_vpc_link
}

