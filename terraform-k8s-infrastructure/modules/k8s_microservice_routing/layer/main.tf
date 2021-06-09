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

data "aws_lb" "load_balancer" {
  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "layer_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
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

// /v1/layer
module "layer_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "layer"
}

// /v1/layer/{layerId}
module "layer_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.layer_resource.aws_api_gateway_resource.id
  path_part   = "{layerId}"
}

// /v1/layer/find-by-ids
module "layer_find_by_ids_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.layer_resource.aws_api_gateway_resource.id
  path_part   = "find-by-ids"
}

// /v1/layer/change-environment
module "layer_change_environment_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.layer_resource.aws_api_gateway_resource.id
  path_part   = "change-environment"
}

// /v1/layer/change-environment/{proxy+}
module "layer_change_environment_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.layer_change_environment_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/dataset/{datasetId}/layer/
module "dataset_id_layer_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_dataset_id_resource.id
  path_part   = "layer"
}

// /v1/dataset/{datasetId}/layer/{layerId}
module "dataset_id_layer_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.dataset_id_layer_resource.aws_api_gateway_resource.id
  path_part   = "{layerId}"
}

// /v1/layer/{layerId}/expire-cache
module "layer_id_expire_cache_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.layer_id_resource.aws_api_gateway_resource.id
  path_part   = "expire-cache"
}

module "layer_get" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.layer_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30546/api/v1/layer"
  vpc_link     = var.vpc_link
}

module "layer_get_dataset_id_layer" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_layer_resource.aws_api_gateway_resource
  method                      = "GET"
  uri                         = "http://${data.aws_lb.load_balancer.dns_name}:30546/api/v1/dataset/{datasetId}/layer"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "layer_get_dataset_id" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_layer_id_resource.aws_api_gateway_resource
  method                      = "GET"
  uri                         = "http://${data.aws_lb.load_balancer.dns_name}:30546/api/v1/dataset/{datasetId}/layer/{layerId}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "layer_get_layer_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.layer_id_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30546/api/v1/layer/{layerId}"
  vpc_link     = var.vpc_link
}

module "layer_post_dataset_id_layer" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_layer_resource.aws_api_gateway_resource
  method                      = "POST"
  uri                         = "http://${data.aws_lb.load_balancer.dns_name}:30546/api/v1/dataset/{datasetId}/layer"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "layer_delete_dataset_id_layer" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_layer_resource.aws_api_gateway_resource
  method                      = "DELETE"
  uri                         = "http://${data.aws_lb.load_balancer.dns_name}:30546/api/v1/dataset/{datasetId}/layer"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "layer_patch_dataset_id_layer_id" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_layer_id_resource.aws_api_gateway_resource
  method                      = "PATCH"
  uri                         = "http://${data.aws_lb.load_balancer.dns_name}:30546/api/v1/dataset/{datasetId}/layer/{layerId}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "layer_any_layer_change_environment_proxy" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = module.layer_change_environment_proxy_resource.aws_api_gateway_resource
  method                      = "ANY"
  uri                         = "http://${data.aws_lb.load_balancer.dns_name}:30546/api/v1/layer/change-environment/{proxy}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "layer_delete_dataset_id_layer_id" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_layer_id_resource.aws_api_gateway_resource
  method                      = "DELETE"
  uri                         = "http://${data.aws_lb.load_balancer.dns_name}:30546/api/v1/dataset/{datasetId}/layer/{layerId}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "layer_post_layer_find_by_ids" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.layer_find_by_ids_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30546/api/v1/layer/find-by-ids"
  vpc_link     = var.vpc_link
}

module "layer_delete_layer_id_expire_cache" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = module.layer_id_expire_cache_resource.aws_api_gateway_resource
  method                      = "DELETE"
  uri                         = "http://${data.aws_lb.load_balancer.dns_name}:30546/api/v1/layer/{layerId}/expire-cache"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["layerId"]
}