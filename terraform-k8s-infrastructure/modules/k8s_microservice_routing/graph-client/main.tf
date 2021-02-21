resource "kubernetes_service" "graph_client_service" {
  metadata {
    name      = "graph-client"
    namespace = "default"

  }
  spec {
    selector = {
      name = "graph-client"
    }
    port {
      port        = 30542
      node_port   = 30542
      target_port = 4500
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "graph_client_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30542
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.graph_client_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "graph_client_lb_target_group" {
  name        = "graph-client-lb-tg"
  port        = 30542
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_graph_client" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.graph_client_lb_target_group.arn
}

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v1/graph
resource "aws_api_gateway_resource" "graph_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "graph"
}

// /v1/graph/query
resource "aws_api_gateway_resource" "graph_query_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_resource.id
  path_part   = "query"
}

// /v1/graph/dataset
resource "aws_api_gateway_resource" "graph_dataset_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_resource.id
  path_part   = "dataset"
}

// /v1/graph/dataset/{datasetId}
resource "aws_api_gateway_resource" "graph_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_dataset_resource.id
  path_part   = "{datasetId}"
}

// /v1/graph/dataset/{datasetId}/visited
resource "aws_api_gateway_resource" "graph_dataset_id_visited_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_dataset_id_resource.id
  path_part   = "visited"
}

// /v1/graph/widget
resource "aws_api_gateway_resource" "graph_widget_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_resource.id
  path_part   = "widget"
}

// /v1/graph/widget/{id}
resource "aws_api_gateway_resource" "graph_widget_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_widget_resource.id
  path_part   = "{id}"
}

// /v1/graph/widget/{id}/{widgetId}
resource "aws_api_gateway_resource" "graph_widget_dataset_id_widget_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_widget_id_resource.id
  path_part   = "{widgetId}"
}

// /v1/graph/layer
resource "aws_api_gateway_resource" "graph_layer_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_resource.id
  path_part   = "layer"
}

// /v1/graph/layer/{id}
resource "aws_api_gateway_resource" "graph_layer_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_layer_resource.id
  path_part   = "{id}"
}

// /v1/graph/layer/{id}/{layerId}
resource "aws_api_gateway_resource" "graph_layer_dataset_id_layer_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_layer_id_resource.id
  path_part   = "{layerId}"
}

// /v1/graph/metadata
resource "aws_api_gateway_resource" "graph_metadata_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_resource.id
  path_part   = "metadata"
}

// /v1/graph/metadata/{resourceTypeOrMetadataId}
resource "aws_api_gateway_resource" "graph_metadata_resource_type_or_metadata_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_metadata_resource.id
  path_part   = "{resourceTypeOrId}"
}

// /v1/graph/metadata/{resourceTypeOrMetadataId}/{resourceId}
resource "aws_api_gateway_resource" "graph_metadata_resource_type_or_metadata_id_resource_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_metadata_resource_type_or_metadata_id_resource.id
  path_part   = "{resourceId}"
}

// /v1/graph/metadata/{resourceTypeOrMetadataId}/{resourceId}/{metadataId}
resource "aws_api_gateway_resource" "graph_metadata_resource_type_or_metadata_id_resource_id_metadata_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_metadata_resource_type_or_metadata_id_resource_id_resource.id
  path_part   = "{metadataId}"
}

// /v1/graph/favourite
resource "aws_api_gateway_resource" "graph_favourite_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_resource.id
  path_part   = "favourite"
}

// /v1/graph/favourite/{resourceType}
resource "aws_api_gateway_resource" "graph_favourite_resource_type_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_favourite_resource.id
  path_part   = "{resourceType}"
}

// /v1/graph/favourite/{resourceType}/{resourceId}
resource "aws_api_gateway_resource" "graph_favourite_resource_type_resource_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_favourite_resource_type_resource.id
  path_part   = "{resourceId}"
}

// /v1/graph/favourite/{resourceType}/{resourceId}/{userId}
resource "aws_api_gateway_resource" "graph_favourite_resource_type_resource_id_user_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_favourite_resource_type_resource_id_resource.id
  path_part   = "{userId}"
}

// /v1/graph/{resourceType}
resource "aws_api_gateway_resource" "graph_resource_type_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_resource.id
  path_part   = "{resourceType}"
}

// /v1/graph/{resourceType}/{resourceId}
resource "aws_api_gateway_resource" "graph_resource_type_resource_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_resource_type_resource.id
  path_part   = "{resourceId}"
}

// /v1/graph/{resourceType}/{resourceId}/associate
resource "aws_api_gateway_resource" "graph_resource_type_resource_id_associate_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_resource_type_resource_id_resource.id
  path_part   = "associate"
}

// /v1/graph/query/similar-dataset
resource "aws_api_gateway_resource" "graph_query_similar_dataset_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_resource.id
  path_part   = "similar-dataset"
}

// /v1/graph/query/similar-dataset/{datasetId}
resource "aws_api_gateway_resource" "graph_query_similar_dataset_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_similar_dataset_resource.id
  path_part   = "{datasetId}"
}

// /v1/graph/query/list-concepts
resource "aws_api_gateway_resource" "graph_query_list_concepts_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_resource.id
  path_part   = "list-concepts"
}

// /v1/graph/query/list-concepts/{datasetId}
resource "aws_api_gateway_resource" "graph_query_list_concepts_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_list_concepts_resource.id
  path_part   = "{datasetId}"
}

// /v1/graph/query/concepts-inferred
resource "aws_api_gateway_resource" "graph_query_concepts_inferred_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_resource.id
  path_part   = "concepts-inferred"
}

// /v1/graph/query/concepts-ancestors
resource "aws_api_gateway_resource" "graph_query_concepts_ancestors_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_resource.id
  path_part   = "concepts-ancestors"
}

// /v1/graph/query/similar-dataset-including-descendent
resource "aws_api_gateway_resource" "graph_query_similar_dataset_including_descendent_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_resource.id
  path_part   = "similar-dataset-including-descendent"
}

// /v1/graph/query/similar-dataset-including-descendent/{datasetId}
resource "aws_api_gateway_resource" "graph_query_similar_dataset_including_descendent_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_similar_dataset_including_descendent_resource.id
  path_part   = "{datasetId}"
}

// /v1/graph/query/search-datasets
resource "aws_api_gateway_resource" "graph_query_search_datasets_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_resource.id
  path_part   = "search-datasets"
}

// /v1/graph/query/search-datasets-ids
resource "aws_api_gateway_resource" "graph_query_search_datasets_ids_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_resource.id
  path_part   = "search-datasets-ids"
}

// /v1/graph/query/most-liked-datasets
resource "aws_api_gateway_resource" "graph_query_most_liked_datasets_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_resource.id
  path_part   = "most-liked-datasets"
}

// /v1/graph/query/most-viewed
resource "aws_api_gateway_resource" "graph_query_most_viewed_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_resource.id
  path_part   = "most-viewed"
}

// /v1/graph/query/most-viewed-by-user
resource "aws_api_gateway_resource" "graph_query_most_viewed_by_user_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_resource.id
  path_part   = "most-viewed-by-user"
}

// /v1/graph/query/search-by-label-synonyms
resource "aws_api_gateway_resource" "graph_query_search_by_label_synonyms_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_resource.id
  path_part   = "search-by-label-synonyms"
}

// /v1/graph/find-by-ids
resource "aws_api_gateway_resource" "graph_find_by_ids_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_resource.id
  path_part   = "find-by-ids"
}

module "graph_client_get_graph_query" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/query"
  vpc_link     = var.vpc_link
}

module "graph_client_post_graph_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_dataset_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/dataset/{datasetId}"
  vpc_link     = var.vpc_link
}

module "graph_client_post_graph_dataset_id_visited" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_dataset_id_visited_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/dataset/{datasetId}/visited"
  vpc_link     = var.vpc_link
}

module "graph_client_post_graph_widget_dataset_id_widget_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_widget_dataset_id_widget_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/widget/{datasetId}/{widgetId}"
  vpc_link     = var.vpc_link
}

module "graph_client_post_graph_layer_dataset_id_layer_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_layer_dataset_id_layer_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/layer/{datasetId}/{layerId}"
  vpc_link     = var.vpc_link
}

module "graph_client_post_graph_metadata_resource_type_or_metadata_id_resource_id_metadata_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_metadata_resource_type_or_metadata_id_resource_id_metadata_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/metadata/{resourceTypeOrMetadataId}/{resourceId}/{metadataId}"
  vpc_link     = var.vpc_link
}

module "graph_client_post_graph_favourite_resource_type_resource_id_user_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_favourite_resource_type_resource_id_user_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/favourite/{resourceType}/{resourceId}/{userId}"
  vpc_link     = var.vpc_link
}

module "graph_client_post_graph_resource_type_resource_id_associate" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_resource_type_resource_id_associate_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/{resourceType}/{resourceId}/associate"
  vpc_link     = var.vpc_link
}

module "graph_client_put_graph_resource_type_resource_id_associate" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_resource_type_resource_id_associate_resource
  method       = "PUT"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/{resourceType}/{resourceId}/associate"
  vpc_link     = var.vpc_link
}

module "graph_client_delete_graph_resource_type_resource_id_associate" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_resource_type_resource_id_associate_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/{resourceType}/{resourceId}/associate"
  vpc_link     = var.vpc_link
}

module "graph_client_delete_graph_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_dataset_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/dataset/{datasetId}"
  vpc_link     = var.vpc_link
}

module "graph_client_delete_graph_widget_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_widget_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/widget/{widgetId}"
  vpc_link     = var.vpc_link
}

module "graph_client_delete_graph_layer_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_layer_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/layer/{layerId}"
  vpc_link     = var.vpc_link
}

module "graph_client_delete_graph_metadata_resource_type_or_metadata_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_metadata_resource_type_or_metadata_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/metadata/{resourceTypeOrMetadataId}"
  vpc_link     = var.vpc_link
}

module "graph_client_delete_graph_favourite_resource_type_resource_id_user_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_favourite_resource_type_resource_id_user_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/favourite/{resourceType}/{resourceId}/{userId}"
  vpc_link     = var.vpc_link
}

module "graph_client_get_graph_query_similar_dataset" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_similar_dataset_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/query/similar-dataset"
  vpc_link     = var.vpc_link
}

module "graph_client_get_graph_query_similar_dataset_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_similar_dataset_dataset_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/query/similar-dataset/{datasetId}"
  vpc_link     = var.vpc_link
}

module "graph_client_get_graph_query_list_concepts" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_list_concepts_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/query/list-concepts"
  vpc_link     = var.vpc_link
}

module "graph_client_get_graph_query_concepts_inferred" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_concepts_inferred_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/query/concepts-inferred"
  vpc_link     = var.vpc_link
}

module "graph_client_post_graph_query_concepts_inferred" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_concepts_inferred_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/query/concepts-inferred"
  vpc_link     = var.vpc_link
}

module "graph_client_get_graph_query_concepts_ancestors" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_concepts_ancestors_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/query/concepts-ancestors"
  vpc_link     = var.vpc_link
}

module "graph_client_post_graph_query_concepts_ancestors" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_concepts_ancestors_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/query/concepts-ancestors"
  vpc_link     = var.vpc_link
}

module "graph_client_get_graph_query_similar_dataset_including_descendent" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_similar_dataset_including_descendent_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/query/similar-dataset-including-descendent"
  vpc_link     = var.vpc_link
}

module "graph_client_get_graph_query_similar_dataset_including_descendent_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_similar_dataset_including_descendent_dataset_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/query/similar-dataset-including-descendent/{datasetId}"
  vpc_link     = var.vpc_link
}

module "graph_client_get_graph_graph_query_search_datasets" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_search_datasets_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/query/search-datasets"
  vpc_link     = var.vpc_link
}

module "graph_client_get_graph_graph_query_search_datasets_ids" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_search_datasets_ids_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/query/search-datasets-ids"
  vpc_link     = var.vpc_link
}

module "graph_client_get_graph_graph_query_most_liked_datasets" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_most_liked_datasets_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/query/most-liked-datasets"
  vpc_link     = var.vpc_link
}

module "graph_client_post_graph_query_search_datasets" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_search_datasets_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/query/search-datasets"
  vpc_link     = var.vpc_link
}

module "graph_client_get_graph_query_most_viewed" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_most_viewed_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/query/most-viewed"
  vpc_link     = var.vpc_link
}

module "graph_client_get_graph_query_most_viewed_by_user" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_most_viewed_by_user_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/query/most-viewed-by-user"
  vpc_link     = var.vpc_link
}

module "graph_client_get_graph_query_search_by_label_synonyms" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_search_by_label_synonyms_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/query/search-by-label-synonyms"
  vpc_link     = var.vpc_link
}

module "graph_client_get_graph_query_list_concepts_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_list_concepts_dataset_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/query/list-concepts/{datasetId}"
  vpc_link     = var.vpc_link
}

module "graph_client_post_graph_find_by_ids" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/query/list-concepts/find-by-ids"
  vpc_link     = var.vpc_link
}