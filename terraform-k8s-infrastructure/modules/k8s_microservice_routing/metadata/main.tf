resource "kubernetes_service" "metadata_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  metadata {
    name      = "metadata"
    namespace = "default"

  }
  spec {
    selector = {
      name = "metadata"
    }
    port {
      port        = 30548
      node_port   = 30548
      target_port = 4000
    }

    type = "NodePort"
  }
}

locals {
  api_gateway_target_url = var.connection_type == "VPC_LINK" ? data.aws_lb.load_balancer[0].dns_name : var.target_url
}

data "aws_lb" "load_balancer" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "metadata_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30548
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.metadata_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "metadata_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  name        = "metadata-lb-tg"
  port        = 30548
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_metadata" {
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  lb_target_group_arn    = aws_lb_target_group.metadata_lb_target_group[0].arn
}

// /v1/metadata
module "metadata_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "metadata"
}

// /v1/dataset/metadata
module "metadata_dataset_metadata_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_dataset_resource.id
  path_part   = "metadata"
}

// /v1/dataset/metadata/find-by-ids
module "metadata_dataset_metadata_find_by_ids_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.metadata_dataset_metadata_resource.aws_api_gateway_resource.id
  path_part   = "find-by-ids"
}

// /v1/dataset/{datasetId}/metadata
module "metadata_dataset_id_metadata_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_dataset_id_resource.id
  path_part   = "metadata"
}

// /v1/dataset/{datasetId}/metadata/clone
module "metadata_dataset_metadata_clone_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.metadata_dataset_id_metadata_resource.aws_api_gateway_resource.id
  path_part   = "clone"
}

// /v1/dataset/{datasetId}/widget/metadata
module "metadata_dataset_id_widget_metadata_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_dataset_id_widget_resource.id
  path_part   = "metadata"
}

// /v1/dataset/{datasetId}/widget/metadata/find-by-ids
module "metadata_dataset_id_widget_metadata_find_by_ids_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.metadata_dataset_id_widget_metadata_resource.aws_api_gateway_resource.id
  path_part   = "find-by-ids"
}

// /v1/dataset/{datasetId}/widget/{widgetId}/metadata
module "metadata_dataset_id_widget_id_metadata_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_dataset_id_widget_id_resource.id
  path_part   = "metadata"
}

// /v1/dataset/{datasetId}/layer/metadata
module "metadata_dataset_id_layer_metadata_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_dataset_id_layer_resource.id
  path_part   = "metadata"
}

// /v1/dataset/{datasetId}/layer/metadata/find-by-ids
module "metadata_dataset_id_layer_metadata_find_by_ids_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.metadata_dataset_id_layer_metadata_resource.aws_api_gateway_resource.id
  path_part   = "find-by-ids"
}

// /v1/dataset/{datasetId}/layer/{layerId}/metadata
module "metadata_dataset_id_layer_id_metadata_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_dataset_id_layer_id_resource.id
  path_part   = "metadata"
}

module "metadata_get" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.metadata_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30548/api/v1/metadata"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

// Dataset
module "metadata_get_for_dataset" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.metadata_dataset_id_metadata_resource.aws_api_gateway_resource
  method                      = "GET"
  uri                         = "http://${local.api_gateway_target_url}:30548/api/v1/dataset/{datasetId}/metadata"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId"]
}

module "metadata_post_for_dataset" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.metadata_dataset_id_metadata_resource.aws_api_gateway_resource
  method                      = "POST"
  uri                         = "http://${local.api_gateway_target_url}:30548/api/v1/dataset/{datasetId}/metadata"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId"]
}

module "metadata_delete_for_dataset" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.metadata_dataset_id_metadata_resource.aws_api_gateway_resource
  method                      = "DELETE"
  uri                         = "http://${local.api_gateway_target_url}:30548/api/v1/dataset/{datasetId}/metadata"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId"]
}

module "metadata_post_for_dataset_clone" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.metadata_dataset_metadata_clone_resource.aws_api_gateway_resource
  method                      = "POST"
  uri                         = "http://${local.api_gateway_target_url}:30548/api/v1/dataset/{datasetId}/metadata/clone"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId"]
}

module "metadata_patch_for_dataset" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.metadata_dataset_id_metadata_resource.aws_api_gateway_resource
  method                      = "PATCH"
  uri                         = "http://${local.api_gateway_target_url}:30548/api/v1/dataset/{datasetId}/metadata"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId"]
}

// Widget
module "metadata_get_for_dataset_widget" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.metadata_dataset_id_widget_id_metadata_resource.aws_api_gateway_resource
  method                      = "GET"
  uri                         = "http://${local.api_gateway_target_url}:30548/api/v1/dataset/{datasetId}/widget/{widgetId}/metadata"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId", "widgetId"]
}

module "metadata_post_for_dataset_widget" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.metadata_dataset_id_widget_id_metadata_resource.aws_api_gateway_resource
  method                      = "POST"
  uri                         = "http://${local.api_gateway_target_url}:30548/api/v1/dataset/{datasetId}/widget/{widgetId}/metadata"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId", "widgetId"]
}

module "metadata_delete_for_dataset_widget" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.metadata_dataset_id_widget_id_metadata_resource.aws_api_gateway_resource
  method                      = "DELETE"
  uri                         = "http://${local.api_gateway_target_url}:30548/api/v1/dataset/{datasetId}/widget/{widgetId}/metadata"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId", "widgetId"]
}

module "metadata_patch_for_dataset_widget" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.metadata_dataset_id_widget_id_metadata_resource.aws_api_gateway_resource
  method                      = "PATCH"
  uri                         = "http://${local.api_gateway_target_url}:30548/api/v1/dataset/{datasetId}/widget/{widgetId}/metadata"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId", "widgetId"]
}

// Layer
module "metadata_get_for_dataset_layer" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.metadata_dataset_id_layer_id_metadata_resource.aws_api_gateway_resource
  method                      = "GET"
  uri                         = "http://${local.api_gateway_target_url}:30548/api/v1/dataset/{datasetId}/layer/{layerId}/metadata"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId", "layerId"]
}

module "metadata_post_for_dataset_layer" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.metadata_dataset_id_layer_id_metadata_resource.aws_api_gateway_resource
  method                      = "POST"
  uri                         = "http://${local.api_gateway_target_url}:30548/api/v1/dataset/{datasetId}/layer/{layerId}/metadata"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId", "layerId"]
}

module "metadata_delete_for_dataset_layer" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.metadata_dataset_id_layer_id_metadata_resource.aws_api_gateway_resource
  method                      = "DELETE"
  uri                         = "http://${local.api_gateway_target_url}:30548/api/v1/dataset/{datasetId}/layer/{layerId}/metadata"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId", "layerId"]
}

module "metadata_patch_for_dataset_layer" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.metadata_dataset_id_layer_id_metadata_resource.aws_api_gateway_resource
  method                      = "PATCH"
  uri                         = "http://${local.api_gateway_target_url}:30548/api/v1/dataset/{datasetId}/layer/{layerId}/metadata"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId", "layerId"]
}

// Find by ids
module "metadata_dataset_post_find_by_ids" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.metadata_dataset_metadata_find_by_ids_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30548/api/v1/dataset/metadata/find-by-ids"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "metadata_layer_post_find_by_ids" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.metadata_dataset_id_layer_metadata_find_by_ids_resource.aws_api_gateway_resource
  method                      = "POST"
  uri                         = "http://${local.api_gateway_target_url}:30548/api/v1/dataset/{datasetId}/layer/metadata/find-by-ids"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId"]
}

module "metadata_widget_post_find_by_ids" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.metadata_dataset_id_widget_metadata_find_by_ids_resource.aws_api_gateway_resource
  method                      = "POST"
  uri                         = "http://${local.api_gateway_target_url}:30548/api/v1/dataset/{datasetId}/widget/metadata/find-by-ids"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId"]
}
