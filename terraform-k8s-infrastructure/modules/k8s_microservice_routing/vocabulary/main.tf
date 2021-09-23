resource "kubernetes_service" "vocabulary_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  metadata {
    name      = "vocabulary"
    namespace = "default"

  }
  spec {
    selector = {
      name = "vocabulary"
    }
    port {
      port        = 30565
      node_port   = 30565
      target_port = 4100
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

resource "aws_lb_listener" "vocabulary_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30565
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vocabulary_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "vocabulary_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  name        = "vocabulary-lb-tg"
  port        = 30565
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_vocabulary" {
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.vocabulary_lb_target_group[0].arn
}

#
# Base and dataset resources
#

// /v1/vocabulary
module "vocabulary_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "vocabulary"
}

// /v1/vocabulary/{proxy+}
module "vocabulary_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.vocabulary_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "vocabulary_get_vocabulary" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.vocabulary_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30565/api/v1/vocabulary"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "vocabulary_post_vocabulary" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.vocabulary_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30565/api/v1/vocabulary"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "vocabulary_any_vocabulary_proxy" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.vocabulary_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30565/api/v1/vocabulary/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

#
# Dataset resources and endpoints
#

// /v1/dataset/{datasetId}/vocabulary
module "dataset_id_vocabulary_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_dataset_id_resource.id
  path_part   = "vocabulary"
}

// /v1/dataset/{datasetId}/vocabulary/{proxy+}
module "dataset_id_vocabulary_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.dataset_id_vocabulary_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/dataset/vocabulary
module "dataset_vocabulary_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_dataset_resource.id
  path_part   = "vocabulary"
}

// /v1/dataset/vocabulary/{proxy+}
module "dataset_vocabulary_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.dataset_vocabulary_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "vocabulary_get_dataset_id_vocabulary" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_vocabulary_resource.aws_api_gateway_resource
  method                      = "GET"
  uri                         = "http://${local.api_gateway_target_url}:30565/api/v1/dataset/{datasetId}/vocabulary"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId"]
}

module "vocabulary_post_dataset_id_vocabulary" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_vocabulary_resource.aws_api_gateway_resource
  method                      = "POST"
  uri                         = "http://${local.api_gateway_target_url}:30565/api/v1/dataset/{datasetId}/vocabulary"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId"]
}

module "vocabulary_put_dataset_id_vocabulary" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_vocabulary_resource.aws_api_gateway_resource
  method                      = "PUT"
  uri                         = "http://${local.api_gateway_target_url}:30565/api/v1/dataset/{datasetId}/vocabulary"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId"]
}

module "vocabulary_any_dataset_id_vocabulary_proxy" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_vocabulary_proxy_resource.aws_api_gateway_resource
  method                      = "ANY"
  uri                         = "http://${local.api_gateway_target_url}:30565/api/v1/dataset/{datasetId}/vocabulary/{proxy}"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId"]
}

module "vocabulary_delete_dataset_id_vocabulary" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_vocabulary_resource.aws_api_gateway_resource
  method                      = "DELETE"
  uri                         = "http://${local.api_gateway_target_url}:30565/api/v1/dataset/{datasetId}/vocabulary"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId"]
}

module "vocabulary_any_dataset_vocabulary_proxy" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.dataset_vocabulary_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30565/api/v1/dataset/vocabulary/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

#
# Widget resources
#

// /v1/dataset/{datasetId}/widget/{widgetId}/vocabulary
module "dataset_id_widget_id_vocabulary_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_dataset_id_widget_id_resource.id
  path_part   = "vocabulary"
}

// /v1/dataset/{datasetId}/widget/{widgetId}/vocabulary/{vocabularyId}
module "dataset_id_widget_id_vocabulary_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.dataset_id_widget_id_vocabulary_resource.aws_api_gateway_resource.id
  path_part   = "{vocabularyId}"
}

// /v1/dataset/{datasetId}/widget/vocabulary
module "dataset_id_widget_vocabulary_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_dataset_id_widget_resource.id
  path_part   = "vocabulary"
}

// /v1/dataset/{datasetId}/widget/vocabulary/{proxy+}
module "dataset_id_widget_vocabulary_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.dataset_id_widget_vocabulary_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "vocabulary_get_dataset_id_widget_id_vocabulary" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_widget_id_vocabulary_resource.aws_api_gateway_resource
  method                      = "GET"
  uri                         = "http://${local.api_gateway_target_url}:30565/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId"]
}

module "vocabulary_get_dataset_id_widget_id_vocabulary_id" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_widget_id_vocabulary_id_resource.aws_api_gateway_resource
  method                      = "GET"
  uri                         = "http://${local.api_gateway_target_url}:30565/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary/{vocabularyId}"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId", "widgetId"]
}

module "vocabulary_post_dataset_id_widget_id_vocabulary" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_widget_id_vocabulary_resource.aws_api_gateway_resource
  method                      = "POST"
  uri                         = "http://${local.api_gateway_target_url}:30565/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId", "widgetId"]
}

module "vocabulary_post_dataset_id_widget_id_vocabulary_id" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_widget_id_vocabulary_id_resource.aws_api_gateway_resource
  method                      = "POST"
  uri                         = "http://${local.api_gateway_target_url}:30565/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary/{vocabularyId}"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId", "widgetId"]
}

module "vocabulary_patch_dataset_id_widget_id_vocabulary_id" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_widget_id_vocabulary_id_resource.aws_api_gateway_resource
  method                      = "PATCH"
  uri                         = "http://${local.api_gateway_target_url}:30565/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary/{vocabularyId}"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId", "widgetId"]
}

module "vocabulary_delete_dataset_id_widget_id_vocabulary" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_widget_id_vocabulary_resource.aws_api_gateway_resource
  method                      = "DELETE"
  uri                         = "http://${local.api_gateway_target_url}:30565/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId", "widgetId"]
}

module "vocabulary_delete_dataset_id_widget_id_vocabulary_id" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_widget_id_vocabulary_id_resource.aws_api_gateway_resource
  method                      = "DELETE"
  uri                         = "http://${local.api_gateway_target_url}:30565/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary/{vocabularyId}"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId", "widgetId"]
}

module "vocabulary_any_dataset_id_widget_vocabulary_proxy" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_widget_vocabulary_proxy_resource.aws_api_gateway_resource
  method                      = "ANY"
  uri                         = "http://${local.api_gateway_target_url}:30565/api/v1/dataset/{datasetId}/widget/vocabulary/{proxy}"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId"]
}

#
# Layer resources
#

// /v1/dataset/{datasetId}/layer/{layerId}/vocabulary
module "dataset_id_layer_id_vocabulary_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_dataset_id_layer_id_resource.id
  path_part   = "vocabulary"
}

// /v1/dataset/{datasetId}/layer/{layerId}/vocabulary/{vocabularyId}
module "dataset_id_layer_id_vocabulary_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.dataset_id_layer_id_vocabulary_resource.aws_api_gateway_resource.id
  path_part   = "{vocabularyId}"
}

// /v1/dataset/{datasetId}/layer/vocabulary
module "dataset_id_layer_vocabulary_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_dataset_id_layer_resource.id
  path_part   = "vocabulary"
}

// /v1/dataset/{datasetId}/layer/vocabulary/{proxy+}
module "dataset_id_layer_vocabulary_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.dataset_id_layer_vocabulary_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "vocabulary_get_dataset_id_layer_id_vocabulary" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_layer_id_vocabulary_resource.aws_api_gateway_resource
  method                      = "GET"
  uri                         = "http://${local.api_gateway_target_url}:30565/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId", "layerId"]
}

module "vocabulary_get_dataset_id_layer_id_vocabulary_id" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_layer_id_vocabulary_id_resource.aws_api_gateway_resource
  method                      = "GET"
  uri                         = "http://${local.api_gateway_target_url}:30565/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary/{vocabularyId}"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId", "layerId"]
}

module "vocabulary_post_dataset_id_layer_id_vocabulary" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_layer_id_vocabulary_resource.aws_api_gateway_resource
  method                      = "POST"
  uri                         = "http://${local.api_gateway_target_url}:30565/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId", "layerId"]
}

module "vocabulary_post_dataset_id_layer_id_vocabulary_id" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_layer_id_vocabulary_id_resource.aws_api_gateway_resource
  method                      = "POST"
  uri                         = "http://${local.api_gateway_target_url}:30565/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary/{vocabularyId}"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId", "layerId"]
}

module "vocabulary_patch_dataset_id_layer_id_vocabulary_id" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_layer_id_vocabulary_id_resource.aws_api_gateway_resource
  method                      = "PATCH"
  uri                         = "http://${local.api_gateway_target_url}:30565/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary/{vocabularyId}"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId", "layerId"]
}

module "vocabulary_delete_dataset_id_layer_id_vocabulary" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_layer_id_vocabulary_resource.aws_api_gateway_resource
  method                      = "DELETE"
  uri                         = "http://${local.api_gateway_target_url}:30565/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId", "layerId"]
}

module "vocabulary_delete_dataset_id_layer_id_vocabulary_id" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_layer_id_vocabulary_id_resource.aws_api_gateway_resource
  method                      = "DELETE"
  uri                         = "http://${local.api_gateway_target_url}:30565/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary/{vocabularyId}"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId", "layerId"]
}

module "vocabulary_any_dataset_id_layer_vocabulary_proxy" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_layer_vocabulary_proxy_resource.aws_api_gateway_resource
  method                      = "ANY"
  uri                         = "http://${local.api_gateway_target_url}:30565/api/v1/dataset/{datasetId}/layer/vocabulary/{proxy}"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId"]
}

#
# Favourites
#

// /v1/favourite
module "favourite_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "favourite"
}

// /v1/favourite/{proxy+}
module "favourite_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.favourite_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "vocabulary_get_favourite" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.favourite_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30565/api/v1/favourite"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "vocabulary_post_favourite" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.favourite_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30565/api/v1/favourite"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "vocabulary_any_favourite_proxy" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.favourite_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30565/api/v1/favourite/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

#
# Collection
#

// /v1/collection
module "collection_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "collection"
}

// /v1/collection/{proxy+}
module "collection_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.collection_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "vocabulary_get_collection" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.collection_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30565/api/v1/collection"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "vocabulary_any_collection_proxy" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.collection_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30565/api/v1/collection/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "vocabulary_post_collection" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.collection_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30565/api/v1/collection"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}
