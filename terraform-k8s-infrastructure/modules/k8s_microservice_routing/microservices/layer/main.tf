resource "kubernetes_service" "layer_service" {
  metadata {
    name      = "layer"
    namespace = "default"

  }
  spec {
    selector = {
      name = "layer"
    }
    port {
      port        = 30546
      node_port   = 30546
      target_port = 6000
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "layer_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30546
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.layer_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "layer_lb_target_group" {
  name        = "layer-lb-tg"
  port        = 30546
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_layer" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.layer_lb_target_group.arn
}

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v1/dataset/{datasetId}
data "aws_api_gateway_resource" "dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/dataset/{datasetId}"
}

// /v1/layer
resource "aws_api_gateway_resource" "layer_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "layer"
}

// /v1/layer/{layerId}
resource "aws_api_gateway_resource" "layer_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.layer_resource.id
  path_part   = "{layerId}"
}

// /v1/layer/find-by-ids
resource "aws_api_gateway_resource" "layer_find_by_ids_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.layer_resource.id
  path_part   = "find-by-ids"
}

// /v1/layer/change-environment
resource "aws_api_gateway_resource" "layer_change_environment_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.layer_resource.id
  path_part   = "change-environment"
}

// /v1/layer/change-environment/{datasetId}
resource "aws_api_gateway_resource" "layer_change_environment_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.layer_change_environment_resource.id
  path_part   = "{datasetId}"
}

// /v1/layer/change-environment/{datasetId}/{env}
resource "aws_api_gateway_resource" "layer_change_environment_dataset_id_env_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.layer_change_environment_dataset_id_resource.id
  path_part   = "{env}"
}

// /v1/dataset/{datasetId}/layer/
resource "aws_api_gateway_resource" "dataset_id_layer_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.dataset_id_resource.id
  path_part   = "layer"
}

// /v1/dataset/{datasetId}/layer/{layerId}
resource "aws_api_gateway_resource" "dataset_id_layer_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_layer_resource.id
  path_part   = "{layerId}"
}

// /v1/layer/{layerId}/expire-cache
resource "aws_api_gateway_resource" "layer_id_expire_cache_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.layer_id_resource.id
  path_part   = "expire-cache"
}

module "layer_get" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.layer_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30546/api/v1/layer"
  vpc_link     = var.vpc_link
}

module "layer_get_dataset_id_layer" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_layer_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30546/api/v1/dataset/{datasetId}/layer"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "layer_get_dataset_id" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_layer_id_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30546/api/v1/dataset/{datasetId}/layer/{layerId}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "layer_get_layer_id" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.layer_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30546/api/v1/layer/{layerId}"
  vpc_link     = var.vpc_link
}

module "layer_post_dataset_id_layer" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_layer_resource
  method                      = "POST"
  uri                         = "http://api.resourcewatch.org:30546/api/v1/dataset/{datasetId}/layer"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "layer_delete_dataset_id_layer" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_layer_resource
  method                      = "DELETE"
  uri                         = "http://api.resourcewatch.org:30546/api/v1/dataset/{datasetId}/layer"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "layer_patch_dataset_id_layer_id" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_layer_id_resource
  method                      = "PATCH"
  uri                         = "http://api.resourcewatch.org:30546/api/v1/dataset/{datasetId}/layer/{layerId}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "layer_patch_layer_change_environment_dataset_id_env" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.layer_change_environment_dataset_id_env_resource
  method                      = "PATCH"
  uri                         = "http://api.resourcewatch.org:30546/api/v1/layer/change-environment/{datasetId}/{env}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "layer_delete_dataset_id_layer_id" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_layer_id_resource
  method                      = "DELETE"
  uri                         = "http://api.resourcewatch.org:30546/api/v1/dataset/{datasetId}/layer/{layerId}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "layer_post_layer_find_by_ids" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.layer_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30546/api/v1/layer/find-by-ids"
  vpc_link     = var.vpc_link
}

module "layer_delete_layer_id_expire_cache" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.layer_id_expire_cache_resource
  method                      = "DELETE"
  uri                         = "http://api.resourcewatch.org:30546/api/v1/layer/{layerId}/expire-cache"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["layerId"]
}