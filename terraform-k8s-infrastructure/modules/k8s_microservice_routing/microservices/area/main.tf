resource "kubernetes_service" "area_service" {
  metadata {
    name      = "area"
    namespace = "gfw"

  }
  spec {
    selector = {
      name = "area"
    }
    port {
      port        = 30504
      node_port   = 30504
      target_port = 4100
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "area_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30504
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.area_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "area_lb_target_group" {
  name        = "area-lb-tg"
  port        = 30504
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_area" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.area_lb_target_group.arn
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

// /v2/area
resource "aws_api_gateway_resource" "v2_area_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v2_resource.id
  path_part   = "area"
}

// /v2/area/{areaId}
resource "aws_api_gateway_resource" "v2_area_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_area_resource.id
  path_part   = "{areaId}"
}

// /v2/area/sync
resource "aws_api_gateway_resource" "v2_area_sync_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_area_resource.id
  path_part   = "sync"
}

// /v2/area/update
resource "aws_api_gateway_resource" "v2_area_update_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_area_resource.id
  path_part   = "update"
}

// /v2/download-tiles
resource "aws_api_gateway_resource" "v2_area_download_tiles_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_area_resource.id
  path_part   = "download-tiles"
}

// /v2/download-tiles/{geostoreId}
resource "aws_api_gateway_resource" "v2_area_download_tiles_geostore_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_area_download_tiles_resource.id
  path_part   = "{geostoreId}"
}

// /v2/download-tiles/{geostoreId}/{minZoom}
resource "aws_api_gateway_resource" "v2_area_download_tiles_geostore_id_min_zoom_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_area_download_tiles_geostore_id_resource.id
  path_part   = "{minZoom}"
}

// /v2/download-tiles/{geostoreId}/{minZoom}/{maxZoom}
resource "aws_api_gateway_resource" "v2_area_download_tiles_geostore_id_min_zoom_max_zoom_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_area_download_tiles_geostore_id_min_zoom_resource.id
  path_part   = "{maxZoom}"
}

// /v1/area
resource "aws_api_gateway_resource" "area_v1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "area"
}

// /v1/area/fw
resource "aws_api_gateway_resource" "area_v1_fw_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.area_v1_resource.id
  path_part   = "area"
}

// /v1/area/fw/{userId}
resource "aws_api_gateway_resource" "area_v1_fw_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.area_v1_fw_resource.id
  path_part   = "{userId}"
}

// /v1/area/{areaId}
resource "aws_api_gateway_resource" "area_v1_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.area_v1_resource.id
  path_part   = "{areaId}"
}

// /v1/area/{areaId}/alerts
resource "aws_api_gateway_resource" "area_v1_id_alerts_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.area_v1_id_resource.id
  path_part   = "alerts"
}

// /v1/download-tiles
resource "aws_api_gateway_resource" "area_v1_download_tiles_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.area_v1_resource.id
  path_part   = "download-tiles"
}

// /v1/download-tiles/{geostoreId}
resource "aws_api_gateway_resource" "area_v1_download_tiles_geostore_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.area_v1_download_tiles_resource.id
  path_part   = "{geostoreId}"
}

// /v1/download-tiles/{geostoreId}/{minZoom}
resource "aws_api_gateway_resource" "area_v1_download_tiles_geostore_id_min_zoom_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.area_v1_download_tiles_geostore_id_resource.id
  path_part   = "{minZoom}"
}

// /v1/download-tiles/{geostoreId}/{minZoom}/{maxZoom}
resource "aws_api_gateway_resource" "area_v1_download_tiles_geostore_id_min_zoom_max_zoom_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.area_v1_download_tiles_geostore_id_min_zoom_resource.id
  path_part   = "{maxZoom}"
}

module "area_get_area_v2" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_area_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30504/api/v2/area"
  vpc_link     = var.vpc_link
}

module "area_get_area_v2_id" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_area_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30504/api/v2/area/{areaId}"
  vpc_link     = var.vpc_link
}

module "area_post_area_v2_sync" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_area_sync_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30504/api/v2/area/sync"
  vpc_link     = var.vpc_link
}

module "area_post_area_v2" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_area_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30504/api/v2/area"
  vpc_link     = var.vpc_link
}

module "area_patch_area_v2_id" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_area_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org:30504/api/v2/area/{areaId}"
  vpc_link     = var.vpc_link
}

module "area_post_area_v2_update" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_area_update_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30504/api/v2/area/update"
  vpc_link     = var.vpc_link
}

module "area_delete_area_v2_id" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_area_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30504/api/v2/area/{areaId}"
  vpc_link     = var.vpc_link
}

module "area_get_area_v2_download_tiles_geostore_id_min_zoom_max_zoom" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.v2_area_download_tiles_geostore_id_min_zoom_max_zoom_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30504/api/v2/area/download-tiles/{geostoreId}/{minZoom}/{maxZoom}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["geostoreId", "minZoom"]
}

module "area_get_area_v1" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v1_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30504/api/v1/area"
  vpc_link     = var.vpc_link
}

module "area_get_area_v1_fw" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v1_fw_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30504/api/v1/area/fw"
  vpc_link     = var.vpc_link
}

module "area_get_area_v1_fw_id" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v1_fw_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30504/api/v1/area/fw/{userId}"
  vpc_link     = var.vpc_link
}

module "area_get_area_v1_id" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v1_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30504/api/v1/area/{areaId}"
  vpc_link     = var.vpc_link
}

module "area_post_area_v1" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v1_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30504/api/v1/area"
  vpc_link     = var.vpc_link
}

module "area_post_area_v1_fw_id" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v1_fw_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30504/api/v1/area/fw/{userId}"
  vpc_link     = var.vpc_link
}

module "area_patch_area_v1_id" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v1_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org:30504/api/v1/area/{areaId}"
  vpc_link     = var.vpc_link
}

module "area_delete_area_v1_id" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.area_v1_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30504/api/v1/area/{areaId}"
  vpc_link     = var.vpc_link
}

module "area_get_area_v1_id_alerts" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.area_v1_id_alerts_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30504/api/v1/area/{areaId}/alerts"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["areaId"]
}

module "area_get_area_v1_download_tiles_geostore_id_min_zoom_max_zoom" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.area_v1_download_tiles_geostore_id_min_zoom_max_zoom_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30504/api/v1/area/download-tiles/{geostoreId}/{minZoom}/{maxZoom}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["geostoreId", "minZoom"]
}