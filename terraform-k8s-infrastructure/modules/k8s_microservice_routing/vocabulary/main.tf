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

// /v1/vocabulary/{proxy+}
resource "aws_api_gateway_resource" "vocabulary_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.vocabulary_resource.id
  path_part   = "{proxy+}"
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

module "vocabulary_any_vocabulary_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.vocabulary_proxy_resource
  method       = "ANY"
  uri          = "http://api.resourcewatch.org:30565/api/v1/vocabulary/{proxy}"
  vpc_link     = var.vpc_link
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

// /v1/dataset/{datasetId}/vocabulary/{proxy+}
resource "aws_api_gateway_resource" "dataset_id_vocabulary_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_vocabulary_resource.id
  path_part   = "{proxy+}"
}

// /v1/dataset/vocabulary
resource "aws_api_gateway_resource" "dataset_vocabulary_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.dataset_resource.id
  path_part   = "vocabulary"
}

// /v1/dataset/vocabulary/{proxy+}
resource "aws_api_gateway_resource" "dataset_vocabulary_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_vocabulary_resource.id
  path_part   = "{proxy+}"
}

module "vocabulary_get_dataset_id_vocabulary" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_vocabulary_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/vocabulary"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "vocabulary_post_dataset_id_vocabulary" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_vocabulary_resource
  method                      = "POST"
  uri                         = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/vocabulary"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "vocabulary_put_dataset_id_vocabulary" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_vocabulary_resource
  method                      = "PUT"
  uri                         = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/vocabulary"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "vocabulary_any_dataset_id_vocabulary_proxy" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_vocabulary_proxy_resource
  method                      = "ANY"
  uri                         = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/vocabulary/{proxy}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "vocabulary_delete_dataset_id_vocabulary" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_vocabulary_resource
  method                      = "DELETE"
  uri                         = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/vocabulary"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "vocabulary_any_dataset_vocabulary_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_vocabulary_proxy_resource
  method       = "ANY"
  uri          = "http://api.resourcewatch.org:30565/api/v1/dataset/vocabulary/{proxy}"
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

// /v1/dataset/{datasetId}/widget/vocabulary/{proxy+}
resource "aws_api_gateway_resource" "dataset_id_widget_vocabulary_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_widget_vocabulary_resource.id
  path_part   = "{proxy+}"
}

module "vocabulary_get_dataset_id_widget_id_vocabulary" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_widget_id_vocabulary_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "vocabulary_get_dataset_id_widget_id_vocabulary_id" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_widget_id_vocabulary_id_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary/{vocabularyId}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId", "widgetId"]
}

module "vocabulary_post_dataset_id_widget_id_vocabulary" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_widget_id_vocabulary_resource
  method                      = "POST"
  uri                         = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId", "widgetId"]
}

module "vocabulary_post_dataset_id_widget_id_vocabulary_id" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_widget_id_vocabulary_id_resource
  method                      = "POST"
  uri                         = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary/{vocabularyId}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId", "widgetId"]
}

module "vocabulary_patch_dataset_id_widget_id_vocabulary_id" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_widget_id_vocabulary_id_resource
  method                      = "PATCH"
  uri                         = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary/{vocabularyId}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId", "widgetId"]
}

module "vocabulary_delete_dataset_id_widget_id_vocabulary" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_widget_id_vocabulary_resource
  method                      = "DELETE"
  uri                         = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId", "widgetId"]
}

module "vocabulary_delete_dataset_id_widget_id_vocabulary_id" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_widget_id_vocabulary_id_resource
  method                      = "DELETE"
  uri                         = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/widget/{widgetId}/vocabulary/{vocabularyId}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId", "widgetId"]
}

module "vocabulary_any_dataset_id_widget_vocabulary_proxy" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_widget_vocabulary_proxy_resource
  method                      = "ANY"
  uri                         = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/widget/vocabulary/{proxy}"
  vpc_link                    = var.vpc_link
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

// /v1/dataset/{datasetId}/layer/vocabulary/{proxy+}
resource "aws_api_gateway_resource" "dataset_id_layer_vocabulary_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_layer_vocabulary_resource.id
  path_part   = "{proxy+}"
}

module "vocabulary_get_dataset_id_layer_id_vocabulary" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_layer_id_vocabulary_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId", "layerId"]
}

module "vocabulary_get_dataset_id_layer_id_vocabulary_id" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_layer_id_vocabulary_id_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary/{vocabularyId}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId", "layerId"]
}

module "vocabulary_post_dataset_id_layer_id_vocabulary" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_layer_id_vocabulary_resource
  method                      = "POST"
  uri                         = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId", "layerId"]
}

module "vocabulary_post_dataset_id_layer_id_vocabulary_id" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_layer_id_vocabulary_id_resource
  method                      = "POST"
  uri                         = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary/{vocabularyId}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId", "layerId"]
}

module "vocabulary_patch_dataset_id_layer_id_vocabulary_id" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_layer_id_vocabulary_id_resource
  method                      = "PATCH"
  uri                         = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary/{vocabularyId}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId", "layerId"]
}

module "vocabulary_delete_dataset_id_layer_id_vocabulary" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_layer_id_vocabulary_resource
  method                      = "DELETE"
  uri                         = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId", "layerId"]
}

module "vocabulary_delete_dataset_id_layer_id_vocabulary_id" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_layer_id_vocabulary_id_resource
  method                      = "DELETE"
  uri                         = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/layer/{layerId}/vocabulary/{vocabularyId}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId", "layerId"]
}

module "vocabulary_any_dataset_id_layer_vocabulary_proxy" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_id_layer_vocabulary_proxy_resource
  method                      = "ANY"
  uri                         = "http://api.resourcewatch.org:30565/api/v1/dataset/{datasetId}/layer/vocabulary/{proxy}"
  vpc_link                    = var.vpc_link
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

// /v1/favourite/{proxy+}
resource "aws_api_gateway_resource" "favourite_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.favourite_resource.id
  path_part   = "{proxy+}"
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

module "vocabulary_any_favourite_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.favourite_proxy_resource
  method       = "ANY"
  uri          = "http://api.resourcewatch.org:30565/api/v1/favourite/{proxy}"
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

// /v1/collection/{proxy+}
resource "aws_api_gateway_resource" "collection_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.collection_resource.id
  path_part   = "{proxy+}"
}

module "vocabulary_get_collection" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.collection_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30565/api/v1/collection"
  vpc_link     = var.vpc_link
}

module "vocabulary_any_collection_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.collection_proxy_resource
  method       = "ANY"
  uri          = "http://api.resourcewatch.org:30565/api/v1/collection/{proxy}"
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
