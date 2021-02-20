
resource "kubernetes_service" "vocabulary_service" {
  metadata {
    name      = "vocabulary"
    namespace = "default"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                 = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=vocabulary"
    }
  }
  spec {
    selector = {
      name = "vocabulary"
    }
    port {
      port        = 80
      target_port = 4100
    }

    type = "LoadBalancer"
  }
}

data "aws_lb" "vocabulary_lb" {
  name = split("-", kubernetes_service.vocabulary_service.status.0.load_balancer.0.ingress.0.hostname).0

  depends_on = [
    kubernetes_service.vocabulary_service
  ]
}

resource "aws_api_gateway_vpc_link" "vocabulary_lb_vpc_link" {
  name        = "Vocabulary LB VPC link"
  description = "VPC link to the vocabulary service load balancer"
  target_arns = [data.aws_lb.vocabulary_lb.arn]

  lifecycle {
    create_before_destroy = true
  }
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
  uri          = "http://api.resourcewatch.org/api/v1/vocabulary"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_post_vocabulary" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.vocabulary_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/vocabulary"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_get_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.vocabulary_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/vocabulary/{vocabularyId}"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_patch_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.vocabulary_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org/api/v1/vocabulary/{vocabularyId}"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_delete_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.vocabulary_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/vocabulary/{vocabularyId}"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_get_vocabulary_id_tags" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.vocabulary_id_tags_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/vocabulary/{vocabularyId}/tags"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
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
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/vocabulary"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_post_dataset_id_vocabulary" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_vocabulary_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/vocabulary"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_put_dataset_id_vocabulary" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_vocabulary_resource
  method       = "PUT"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/vocabulary"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_post_dataset_id_vocabulary_id_concat" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_vocabulary_id_concat_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/vocabulary/{vocabularyId}/concat"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_post_dataset_id_vocabulary_clone_dataset" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_vocabulary_clone_dataset_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/vocabulary/clone/dataset"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_delete_dataset_id_vocabulary" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_vocabulary_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/vocabulary"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_get_dataset_id_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_vocabulary_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/vocabulary/{vocabularyId}"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_post_dataset_id_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_vocabulary_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/vocabulary/{vocabularyId}"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_get_dataset_vocabulary_find" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_vocabulary_find_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/vocabulary/find"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_patch_dataset_by_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_vocabulary_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/vocabulary/{vocabularyId}"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_delete_dataset_by_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_vocabulary_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/vocabulary/{vocabularyId}"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_post_dataset_vocabulary_find_by_ids" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_vocabulary_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/vocabulary/find-by-ids"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
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
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_get_dataset_id_widget_id_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_vocabulary_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary/{vocabularyId}"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_post_dataset_id_widget_id_vocabulary" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_vocabulary_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_post_dataset_id_widget_id_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_vocabulary_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary/{vocabularyId}"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_patch_dataset_id_widget_id_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_vocabulary_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary/{vocabularyId}"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_delete_dataset_id_widget_id_vocabulary" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_vocabulary_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_delete_dataset_id_widget_id_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_vocabulary_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary/{vocabularyId}"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_get_dataset_id_widget_vocabulary_find" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_vocabulary_find_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget/vocabulary/find"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_post_dataset_id_widget_vocabulary_find_by_ids" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_vocabulary_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget/vocabulary/find-by-ids"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
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
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_get_dataset_id_layer_id_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_layer_id_vocabulary_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary/{vocabularyId}"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_post_dataset_id_layer_id_vocabulary" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_layer_id_vocabulary_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_post_dataset_id_layer_id_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_layer_id_vocabulary_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary/{vocabularyId}"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_patch_dataset_id_layer_id_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_layer_id_vocabulary_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary/{vocabularyId}"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_delete_dataset_id_layer_id_vocabulary" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_layer_id_vocabulary_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_delete_dataset_id_layer_id_vocabulary_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_layer_id_vocabulary_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary/{vocabularyId}"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_get_dataset_id_layer_vocabulary_find" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_layer_vocabulary_find_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/layer/vocabulary/find"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_post_dataset_id_layer_vocabulary_find_by_ids" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_layer_vocabulary_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/layer/vocabulary/find-by-ids"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
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
  uri          = "http://api.resourcewatch.org/api/v1/favourite"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_post_favourite" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.favourite_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/favourite"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_get_favourite_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.favourite_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/favourite/{favouriteId}"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_delete_favourite_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.favourite_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/favourite/{favouriteId}"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_post_favourite_find_by_user" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.favourite_find_by_user_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/favourite/find-by-user"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
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
  uri          = "http://api.resourcewatch.org/api/v1/collection"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_get_collection_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.collection_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/collection/{collectionId}"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_post_collection" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.collection_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/collection"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_patch_collection_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.collection_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org/api/v1/collection/{collectionId}"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_delete_collection_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.collection_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/collection/{collectionId}"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_post_collection_id_resource" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.collection_id_resource_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/collection/{collectionId}/resource"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_delete_collection_id_resource_type_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.collection_id_resource_type_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/collection/{collectionId}/resource/{resourceType}/{resourceId}"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}

module "vocabulary_post_collection_find_by_ids" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.collection_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/collection/find-by-ids"
  vpc_link     = aws_api_gateway_vpc_link.vocabulary_lb_vpc_link
}