provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

resource "kubernetes_service" "area_service" {
  metadata {
    name      = "area"
    namespace = "default"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                 = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=area"
    }
  }
  spec {
    selector = {
      name = "area"
    }
    port {
      port        = 80
      target_port = 4100
    }

    type = "LoadBalancer"
  }
}

data "aws_lb" "area_lb" {
  name = split("-", kubernetes_service.area_service.status.0.load_balancer.0.ingress.0.hostname).0

  depends_on = [
    kubernetes_service.area_service
  ]
}

resource "aws_api_gateway_vpc_link" "area_lb_vpc_link" {
  name        = "Area LB VPC link"
  description = "VPC link to the area service load balancer"
  target_arns = [data.aws_lb.area_lb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

// /api/v2/area
resource "aws_api_gateway_resource" "area_v2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.resource_root_v2_id
  path_part   = "area"
}

// /api/v2/area/{areaId}
resource "aws_api_gateway_resource" "area_v2_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.area_v2_resource.id
  path_part   = "{areaId}"
}

// /api/v2/area/sync
resource "aws_api_gateway_resource" "area_v2_sync_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.area_v2_resource.id
  path_part   = "sync"
}

// /api/v2/area/update
resource "aws_api_gateway_resource" "area_v2_update_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.area_v2_resource.id
  path_part   = "update"
}

// /api/v2/download-tiles
resource "aws_api_gateway_resource" "area_v2_download_tiles_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.area_v2_resource.id
  path_part   = "download-tiles"
}

// /api/v2/download-tiles/{geostoreId}
resource "aws_api_gateway_resource" "area_v2_download_tiles_geostoreid_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.area_v2_download_tiles_resource.id
  path_part   = "{geostoreId}"
}

// /api/v2/download-tiles/{geostoreId}/{minZoom}
resource "aws_api_gateway_resource" "area_v2_download_tiles_geostoreid_minzoom_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.area_v2_download_tiles_geostoreid_resource.id
  path_part   = "{minZoom}"
}

// /api/v2/download-tiles/{geostoreId}/{minZoom}/{maxZoom}
resource "aws_api_gateway_resource" "area_v2_download_tiles_geostoreid_minzoom_maxzoom_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.area_v2_download_tiles_geostoreid_minzoom_resource.id
  path_part   = "{maxZoom}"
}

// /api/v1/area
resource "aws_api_gateway_resource" "area_v1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.resource_root_v1_id
  path_part   = "area"
}

// /api/v1/area/fw
resource "aws_api_gateway_resource" "area_v1_fw_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.area_v1_resource
  path_part   = "area"
}

// /api/v1/area/fw/{userId}
resource "aws_api_gateway_resource" "area_v1_fw_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.area_v1_fw_resource.id
  path_part   = "{userId}"
}

// /api/v1/area/{areaId}
resource "aws_api_gateway_resource" "area_v1_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.area_v1_resource.id
  path_part   = "{areaId}"
}

// /api/v1/area/{areaId}/alerts
resource "aws_api_gateway_resource" "area_v1_id_alerts_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.area_v1_id_resource.id
  path_part   = "alerts"
}

// /api/v1/download-tiles
resource "aws_api_gateway_resource" "area_v1_download_tiles_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.area_v1_resource.id
  path_part   = "download-tiles"
}

// /api/v1/download-tiles/{geostoreId}
resource "aws_api_gateway_resource" "area_v1_download_tiles_geostoreid_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.area_v1_download_tiles_resource.id
  path_part   = "{geostoreId}"
}

// /api/v1/download-tiles/{geostoreId}/{minZoom}
resource "aws_api_gateway_resource" "area_v1_download_tiles_geostoreid_minzoom_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.area_v1_download_tiles_geostoreid_resource.id
  path_part   = "{minZoom}"
}

// /api/v1/download-tiles/{geostoreId}/{minZoom}/{maxZoom}
resource "aws_api_gateway_resource" "area_v1_download_tiles_geostoreid_minzoom_maxzoom_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.area_v1_download_tiles_geostoreid_minzoom_resource.id
  path_part   = "{maxZoom}"
}

module "area_get_area_v2" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v2_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/area"
  vpc_link     = aws_api_gateway_vpc_link.area_lb_vpc_link
}

module "area_get_area_v2_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v2_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/area/{areaId}"
  vpc_link     = aws_api_gateway_vpc_link.area_lb_vpc_link
}

module "area_post_area_v2_sync" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v2_sync_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v2/area/sync"
  vpc_link     = aws_api_gateway_vpc_link.area_lb_vpc_link
}

module "area_post_area_v2" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v2_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v2/area"
  vpc_link     = aws_api_gateway_vpc_link.area_lb_vpc_link
}

module "area_patch_area_v2_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v2_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org/api/v2/area/{areaId}"
  vpc_link     = aws_api_gateway_vpc_link.area_lb_vpc_link
}

module "area_post_area_v2_update" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v2_update_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v2/area/update"
  vpc_link     = aws_api_gateway_vpc_link.area_lb_vpc_link
}

module "area_delete_area_v2_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v2_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v2/area/{areaId}"
  vpc_link     = aws_api_gateway_vpc_link.area_lb_vpc_link
}

module "area_get_area_v2_download_tiles_geostoreid_minzoom_maxzoom" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v2_download_tiles_geostoreid_minzoom_maxzoom_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/area/download-tiles/{geostoreId}/{minZoom}/{maxZoom}"
  vpc_link     = aws_api_gateway_vpc_link.area_lb_vpc_link
}

module "area_get_area_v1" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v1_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/area"
  vpc_link     = aws_api_gateway_vpc_link.area_lb_vpc_link
}

module "area_get_area_v1_fw" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v1_fw_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/area/fw"
  vpc_link     = aws_api_gateway_vpc_link.area_lb_vpc_link
}

module "area_get_area_v1_fw_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v1_fw_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/area/fw/{userId}"
  vpc_link     = aws_api_gateway_vpc_link.area_lb_vpc_link
}

module "area_get_area_v1_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v1_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/area/{areaId}"
  vpc_link     = aws_api_gateway_vpc_link.area_lb_vpc_link
}

module "area_post_area_v1" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v1_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/area"
  vpc_link     = aws_api_gateway_vpc_link.area_lb_vpc_link
}

module "area_post_area_v1_fw_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v1_fw_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/area/fw/{userId}"
  vpc_link     = aws_api_gateway_vpc_link.area_lb_vpc_link
}

module "area_patch_area_v1_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v1_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org/api/v1/area/{areaId}"
  vpc_link     = aws_api_gateway_vpc_link.area_lb_vpc_link
}

module "area_delete_area_v1_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v1_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/area/{areaId}"
  vpc_link     = aws_api_gateway_vpc_link.area_lb_vpc_link
}

module "area_get_area_v1_id_alerts" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v1_id_alerts_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/area/{areaId}/alerts"
  vpc_link     = aws_api_gateway_vpc_link.area_lb_vpc_link
}

module "area_get_area_v1_download_tiles_geostoreid_minzoom_maxzoom" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v1_download_tiles_geostoreid_minzoom_maxzoom_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/area/download-tiles/{geostoreId}/{minZoom}/{maxZoom}"
  vpc_link     = aws_api_gateway_vpc_link.area_lb_vpc_link
}