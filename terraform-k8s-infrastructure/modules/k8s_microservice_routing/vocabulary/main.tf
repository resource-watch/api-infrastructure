resource "kubernetes_service" "vocabulary_service" {
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

resource "aws_lb_listener" "vocabulary_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30565
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vocabulary_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "vocabulary_lb_target_group" {
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
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.vocabulary_lb_target_group.arn
}

#
# Base and dataset resources
#

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v1/dataset
data "aws_api_gateway_resource" "dataset_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/dataset"
}

// /v1/dataset/{datasetId}
data "aws_api_gateway_resource" "dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/dataset/{datasetId}"
}

// /v1/vocabulary
resource "aws_api_gateway_resource" "vocabulary_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "vocabulary"
}

// /v1/vocabulary/{vocabularyId}
resource "aws_api_gateway_resource" "vocabulary_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.vocabulary_resource.id
  path_part   = "{vocabularyId}"
}

// /v1/vocabulary/{vocabularyId}/tags
resource "aws_api_gateway_resource" "vocabulary_id_tags_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.vocabulary_id_resource.id
  path_part   = "tags"
}

module "vocabulary_get_vocabulary" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.vocabulary_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30565/api/v1/vocabulary"
  vpc_link     = var.vpc_link
}

module "vocabulary_post_vocabulary" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.vocabulary_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30565/api/v1/vocabulary"
  vpc_link     = var.vpc_link
}

module "vocabulary_get_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.vocabulary_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30565/api/v1/vocabulary/{vocabularyId}"
  vpc_link     = var.vpc_link
}

module "vocabulary_patch_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.vocabulary_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org:30565/api/v1/vocabulary/{vocabularyId}"
  vpc_link     = var.vpc_link
}

module "vocabulary_delete_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.vocabulary_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30565/api/v1/vocabulary/{vocabularyId}"
  vpc_link     = var.vpc_link
}

module "vocabulary_get_vocabulary_id_tags" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.vocabulary_id_tags_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30565/api/v1/vocabulary/{vocabularyId}/tags"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["vocabularyId"]
}


#
# Dataset resources and endpoints
#

// /v1/dataset/{datasetId}/vocabulary
resource "aws_api_gateway_resource" "dataset_id_vocabulary_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.dataset_id_resource.id
  path_part   = "vocabulary"
}

// /v1/dataset/{datasetId}/vocabulary/{vocabularyId}
resource "aws_api_gateway_resource" "dataset_id_vocabulary_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_vocabulary_resource.id
  path_part   = "{vocabularyId}"
}

// /v1/dataset/{datasetId}/vocabulary/{vocabularyId}/concat
resource "aws_api_gateway_resource" "dataset_id_vocabulary_id_concat_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_vocabulary_id_resource.id
  path_part   = "concat"
}

// /v1/dataset/{datasetId}/vocabulary/clone
resource "aws_api_gateway_resource" "dataset_id_vocabulary_clone_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_vocabulary_resource.id
  path_part   = "clone"
}

// /v1/dataset/{datasetId}/vocabulary/clone/dataset
resource "aws_api_gateway_resource" "dataset_id_vocabulary_clone_dataset_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_vocabulary_clone_resource.id
  path_part   = "dataset"
}

// /v1/dataset/vocabulary
resource "aws_api_gateway_resource" "dataset_vocabulary_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.dataset_resource.id
  path_part   = "vocabulary"
}

// /v1/dataset/vocabulary/find
resource "aws_api_gateway_resource" "dataset_vocabulary_find_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_vocabulary_resource.id
  path_part   = "dataset"
}

// /v1/dataset/vocabulary/find-by-ids
resource "aws_api_gateway_resource" "dataset_vocabulary_find_by_ids_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_vocabulary_resource.id
  path_part   = "find-by-ids"
}

module "vocabulary_get_dataset_id_vocabulary" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_vocabulary_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/vocabulary"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "vocabulary_post_dataset_id_vocabulary" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_vocabulary_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/vocabulary"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "vocabulary_put_dataset_id_vocabulary" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_vocabulary_resource
  method       = "PUT"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/vocabulary"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "vocabulary_post_dataset_id_vocabulary_id_concat" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_vocabulary_id_concat_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/vocabulary/{vocabularyId}/concat"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId", "vocabularyId"]
}

module "vocabulary_post_dataset_id_vocabulary_clone_dataset" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_vocabulary_clone_dataset_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/vocabulary/clone/dataset"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "vocabulary_delete_dataset_id_vocabulary" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_vocabulary_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/vocabulary"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "vocabulary_get_dataset_id_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_vocabulary_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/vocabulary/{vocabularyId}"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "vocabulary_post_dataset_id_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_vocabulary_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/vocabulary/{vocabularyId}"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "vocabulary_get_dataset_vocabulary_find" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_vocabulary_find_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/vocabulary/find"
  vpc_link     = var.vpc_link
}

module "vocabulary_patch_dataset_by_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_vocabulary_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/vocabulary/{vocabularyId}"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "vocabulary_delete_dataset_by_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_vocabulary_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/vocabulary/{vocabularyId}"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "vocabulary_post_dataset_vocabulary_find_by_ids" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_vocabulary_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/vocabulary/find-by-ids"
  vpc_link     = var.vpc_link
}


#
# Widget resources
#
// /v1/dataset/{datasetId}/widget
data "aws_api_gateway_resource" "dataset_id_widget_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/dataset/{datasetId}/widget"
}

// /v1/dataset/{datasetId}/widget/{widgetId}
data "aws_api_gateway_resource" "dataset_id_widget_id_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/dataset/{datasetId}/widget/{widgetId}"
}

// /v1/dataset/{datasetId}/widget/{widgetId}/vocabulary
resource "aws_api_gateway_resource" "dataset_id_widget_id_vocabulary_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.dataset_id_widget_id_resource.id
  path_part   = "vocabulary"
}

// /v1/dataset/{datasetId}/widget/{widgetId}/vocabulary/{vocabularyId}
resource "aws_api_gateway_resource" "dataset_id_widget_id_vocabulary_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_widget_id_vocabulary_resource.id
  path_part   = "{vocabularyId}"
}

// /v1/dataset/{datasetId}/widget/vocabulary
resource "aws_api_gateway_resource" "dataset_id_widget_vocabulary_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.dataset_id_widget_resource.id
  path_part   = "vocabulary"
}

// /v1/dataset/{datasetId}/widget/vocabulary/find
resource "aws_api_gateway_resource" "dataset_id_widget_vocabulary_find_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_widget_vocabulary_resource.id
  path_part   = "find"
}

// /v1/dataset/{datasetId}/widget/vocabulary/find-by-ids
resource "aws_api_gateway_resource" "dataset_id_widget_vocabulary_find_by_ids_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_widget_vocabulary_resource.id
  path_part   = "find-by-ids"
}

module "vocabulary_get_dataset_id_widget_id_vocabulary" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_vocabulary_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "vocabulary_get_dataset_id_widget_id_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_vocabulary_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary/{vocabularyId}"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId", "widgetId"]
}

module "vocabulary_post_dataset_id_widget_id_vocabulary" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_vocabulary_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId", "widgetId"]
}

module "vocabulary_post_dataset_id_widget_id_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_vocabulary_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary/{vocabularyId}"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId", "widgetId"]
}

module "vocabulary_patch_dataset_id_widget_id_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_vocabulary_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary/{vocabularyId}"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId", "widgetId"]
}

module "vocabulary_delete_dataset_id_widget_id_vocabulary" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_vocabulary_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId", "widgetId"]
}

module "vocabulary_delete_dataset_id_widget_id_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_vocabulary_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary/{vocabularyId}"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId", "widgetId"]
}

module "vocabulary_get_dataset_id_widget_vocabulary_find" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_vocabulary_find_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/widget/vocabulary/find"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "vocabulary_post_dataset_id_widget_vocabulary_find_by_ids" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_vocabulary_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/widget/vocabulary/find-by-ids"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}


#
# Layer resources
#
// /v1/dataset/{datasetId}/layer
data "aws_api_gateway_resource" "dataset_id_layer_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/dataset/{datasetId}/layer"
}

// /v1/dataset/{datasetId}/layer/{layerId}
data "aws_api_gateway_resource" "dataset_id_layer_id_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/dataset/{datasetId}/layer/{layerId}"
}

// /v1/dataset/{datasetId}/layer/{layerId}/vocabulary
resource "aws_api_gateway_resource" "dataset_id_layer_id_vocabulary_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.dataset_id_layer_id_resource.id
  path_part   = "vocabulary"
}

// /v1/dataset/{datasetId}/layer/{layerId}/vocabulary/{vocabularyId}
resource "aws_api_gateway_resource" "dataset_id_layer_id_vocabulary_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_layer_id_vocabulary_resource.id
  path_part   = "{vocabularyId}"
}

// /v1/dataset/{datasetId}/layer/vocabulary
resource "aws_api_gateway_resource" "dataset_id_layer_vocabulary_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.dataset_id_layer_resource.id
  path_part   = "vocabulary"
}

// /v1/dataset/{datasetId}/layer/vocabulary/find
resource "aws_api_gateway_resource" "dataset_id_layer_vocabulary_find_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_layer_vocabulary_resource.id
  path_part   = "find"
}

// /v1/dataset/{datasetId}/layer/vocabulary/find-by-ids
resource "aws_api_gateway_resource" "dataset_id_layer_vocabulary_find_by_ids_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_layer_vocabulary_resource.id
  path_part   = "find-by-ids"
}

module "vocabulary_get_dataset_id_layer_id_vocabulary" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_layer_id_vocabulary_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId", "layerId"]
}

module "vocabulary_get_dataset_id_layer_id_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_layer_id_vocabulary_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary/{vocabularyId}"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId", "layerId"]
}

module "vocabulary_post_dataset_id_layer_id_vocabulary" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_layer_id_vocabulary_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId", "layerId"]
}

module "vocabulary_post_dataset_id_layer_id_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_layer_id_vocabulary_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary/{vocabularyId}"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId", "layerId"]
}

module "vocabulary_patch_dataset_id_layer_id_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_layer_id_vocabulary_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary/{vocabularyId}"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId", "layerId"]
}

module "vocabulary_delete_dataset_id_layer_id_vocabulary" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_layer_id_vocabulary_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId", "layerId"]
}

module "vocabulary_delete_dataset_id_layer_id_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_layer_id_vocabulary_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary/{vocabularyId}"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId", "layerId"]
}

module "vocabulary_get_dataset_id_layer_vocabulary_find" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_layer_vocabulary_find_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/layer/vocabulary/find"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "vocabulary_post_dataset_id_layer_vocabulary_find_by_ids" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_layer_vocabulary_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/layer/vocabulary/find-by-ids"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}


#
# Favourites
#

// /v1/favourite
resource "aws_api_gateway_resource" "favourite_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "favourite"
}

// /v1/favourite/{favouriteId}
resource "aws_api_gateway_resource" "favourite_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.favourite_resource.id
  path_part   = "{favouriteId}"
}

// /v1/favourite/find-by-user
resource "aws_api_gateway_resource" "favourite_find_by_user_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.favourite_resource.id
  path_part   = "find-by-user"
}

module "vocabulary_get_favourite" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.favourite_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30565/api/v1/favourite"
  vpc_link     = var.vpc_link
}

module "vocabulary_post_favourite" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.favourite_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30565/api/v1/favourite"
  vpc_link     = var.vpc_link
}

module "vocabulary_get_favourite_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.favourite_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30565/api/v1/favourite/{favouriteId}"
  vpc_link     = var.vpc_link
}

module "vocabulary_delete_favourite_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.favourite_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30565/api/v1/favourite/{favouriteId}"
  vpc_link     = var.vpc_link
}

module "vocabulary_post_favourite_find_by_user" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.favourite_find_by_user_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30565/api/v1/favourite/find-by-user"
  vpc_link     = var.vpc_link
}


#
# Collection
#

// /v1/collection
resource "aws_api_gateway_resource" "collection_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "collection"
}

// /v1/collection/{collectionId}
resource "aws_api_gateway_resource" "collection_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.collection_resource.id
  path_part   = "{collectionId}"
}

// /v1/collection/{collectionId}/resource
resource "aws_api_gateway_resource" "collection_id_resource_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.collection_id_resource.id
  path_part   = "resource"
}

// /v1/collection/{collectionId}/resource/{resourceType}
resource "aws_api_gateway_resource" "collection_id_resource_type_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.collection_id_resource_resource.id
  path_part   = "{resourceType}"
}

// /v1/collection/{collectionId}/resource/{resourceType}/{resourceId}
resource "aws_api_gateway_resource" "collection_id_resource_type_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.collection_id_resource_type_resource.id
  path_part   = "{resourceId}"
}

// /v1/collection/find-by-ids
resource "aws_api_gateway_resource" "collection_find_by_ids_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.collection_resource.id
  path_part   = "find-by-ids"
}

module "vocabulary_get_collection" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.collection_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30565/api/v1/collection"
  vpc_link     = var.vpc_link
}

module "vocabulary_get_collection_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.collection_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30565/api/v1/collection/{collectionId}"
  vpc_link     = var.vpc_link
}

module "vocabulary_post_collection" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.collection_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30565/api/v1/collection"
  vpc_link     = var.vpc_link
}

module "vocabulary_patch_collection_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.collection_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org:30565/api/v1/collection/{collectionId}"
  vpc_link     = var.vpc_link
}

module "vocabulary_delete_collection_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.collection_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30565/api/v1/collection/{collectionId}"
  vpc_link     = var.vpc_link
}

module "vocabulary_post_collection_id_resource" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.collection_id_resource_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30565/api/v1/collection/{collectionId}/resource"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["collectionId"]
}

module "vocabulary_delete_collection_id_resource_type_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.collection_id_resource_type_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30565/api/v1/collection/{collectionId}/resource/{resourceType}/{resourceId}"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["collectionId", "resourceType"]
}

module "vocabulary_post_collection_find_by_ids" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.collection_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30565/api/v1/collection/find-by-ids"
  vpc_link     = var.vpc_link
}