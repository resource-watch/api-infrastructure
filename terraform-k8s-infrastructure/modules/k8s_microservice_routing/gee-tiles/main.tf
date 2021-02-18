provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

resource "kubernetes_service" "gee_tiles_service" {
  metadata {
    name = "gee-tiles"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                 = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=gee-tiles"
    }
  }
  spec {
    selector = {
      name = "gee-tiles"
    }
    port {
      port        = 80
      target_port = 5700
    }

    type = "LoadBalancer"
  }
}

data "aws_lb" "gee_tiles_lb" {
  name = split("-", kubernetes_service.gee_tiles_service.status.0.load_balancer.0.ingress.0.hostname).0

  depends_on = [
    kubernetes_service.gee_tiles_service
  ]
}

resource "aws_api_gateway_vpc_link" "gee_tiles_lb_vpc_link" {
  name        = "GEE Tiles LB VPC link"
  description = "VPC link to the gee_tiles service load balancer"
  target_arns = [data.aws_lb.gee_tiles_lb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

// /v1/layer
data "aws_api_gateway_resource" "layer" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/layer"
}

// /v1/layer/{layerId}
data "aws_api_gateway_resource" "layer_id" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/layer/{layerId}"
}

// /v1/layer/{layerId}/tile
resource "aws_api_gateway_resource" "gee_tiles_layer_id_tile_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.layer_id.id
  path_part   = "tile"
}

// /v1/layer/{layerId}/tile/gee
resource "aws_api_gateway_resource" "gee_tiles_layer_id_tile_gee_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.gee_tiles_layer_id_tile_resource.id
  path_part   = "gee"
}

// /v1/layer/{layerId}/tile/gee/{z}
resource "aws_api_gateway_resource" "gee_tiles_layer_id_tile_gee_z_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.gee_tiles_layer_id_tile_gee_resource.id
  path_part   = "{z}"
}

// /v1/layer/{layerId}/tile/gee/{z}/{x}
resource "aws_api_gateway_resource" "gee_tiles_layer_id_tile_gee_z_x_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.gee_tiles_layer_id_tile_gee_z_resource.id
  path_part   = "{x}"
}

// /v1/layer/{layerId}/tile/gee/{z}/{x}/{y}
resource "aws_api_gateway_resource" "gee_tiles_layer_id_tile_gee_z_x_y_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.gee_tiles_layer_id_tile_gee_z_x_resource.id
  path_part   = "{y}"
}

// /v1/layer/gee
resource "aws_api_gateway_resource" "gee_layer_gee_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.layer.id
  path_part   = "gee"
}

// /v1/layer/gee/{layerId}
resource "aws_api_gateway_resource" "gee_layer_gee_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.gee_layer_gee_resource.id
  path_part   = "{layerId}"
}

// /v1/layer/gee/{layerId}/expire-cache
resource "aws_api_gateway_resource" "gee_layer_gee_id_expire_cache_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.gee_layer_gee_id_resource.id
  path_part   = "expire-cache"
}

module "gee_tiles_get_layer_id_tile_gee_z_x_y" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.gee_tiles_layer_id_tile_gee_z_x_y_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/layer/{layerId}/tile/gee/{z}/{x}/{y}"
  vpc_link     = aws_api_gateway_vpc_link.gee_tiles_lb_vpc_link
}

module "gee_tiles_delete_gee_layer_gee_id_expire_cache" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.gee_layer_gee_id_expire_cache_resource
  method         = "DELETE"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/layer/gee/{layerId}/expire-cache"
  vpc_link       = aws_api_gateway_vpc_link.gee_tiles_lb_vpc_link
}