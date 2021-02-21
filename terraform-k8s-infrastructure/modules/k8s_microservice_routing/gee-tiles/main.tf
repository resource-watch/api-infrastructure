resource "kubernetes_service" "gee_tiles_service" {
  metadata {
    name = "gee-tiles"

  }
  spec {
    selector = {
      name = "gee-tiles"
    }
    port {
      port        = 30531
      node_port   = 30531
      target_port = 5700
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "gee_tiles_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30531
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gee_tiles_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "gee_tiles_lb_target_group" {
  name        = "gee-tiles-lb-tg"
  port        = 30531
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_gee_tiles" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.gee_tiles_lb_target_group.arn
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
  uri          = "http://api.resourcewatch.org:30531/api/v1/layer/{layerId}/tile/gee/{z}/{x}/{y}"
  vpc_link     = var.vpc_link
}

module "gee_tiles_delete_gee_layer_gee_id_expire_cache" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.gee_layer_gee_id_expire_cache_resource
  method         = "DELETE"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org:30531/api/v1/layer/gee/{layerId}/expire-cache"
  vpc_link       = var.vpc_link
}