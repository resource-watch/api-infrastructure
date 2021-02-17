provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

resource "kubernetes_service" "graph_client_service" {
  metadata {
    name      = "graph-client"
    namespace = "default"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                 = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=graph-client"
    }
  }
  spec {
    selector = {
      name = "graph-client"
    }
    port {
      port        = 80
      target_port = 4500
    }

    type = "LoadBalancer"
  }
}

data "aws_lb" "graph_client_lb" {
  name = split("-", kubernetes_service.graph_client_service.status.0.load_balancer.0.ingress.0.hostname).0

  depends_on = [
    kubernetes_service.graph_client_service
  ]
}

resource "aws_api_gateway_vpc_link" "graph_client_lb_vpc_link" {
  name        = "Graph_client LB VPC link"
  description = "VPC link to the graph_client service load balancer"
  target_arns = [data.aws_lb.graph_client_lb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

// /api/v1/graph
resource "aws_api_gateway_resource" "graph_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.resource_root_id
  path_part   = "graph"
}

// /api/v1/graph/query
resource "aws_api_gateway_resource" "graph_query_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_resource.id
  path_part   = "query"
}

// /api/v1/graph/dataset
resource "aws_api_gateway_resource" "graph_dataset_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_resource.id
  path_part   = "dataset"
}

// /api/v1/graph/dataset/{datasetId}
resource "aws_api_gateway_resource" "graph_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_dataset_resource.id
  path_part   = "{datasetId}"
}

// /api/v1/graph/dataset/{datasetId}/visited
resource "aws_api_gateway_resource" "graph_dataset_id_visited_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_dataset_id_resource.id
  path_part   = "visited"
}

// /api/v1/graph/widget
resource "aws_api_gateway_resource" "graph_widget_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_resource.id
  path_part   = "widget"
}

// /api/v1/graph/widget/{id}
resource "aws_api_gateway_resource" "graph_widget_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_widget_resource.id
  path_part   = "{id}"
}

// /api/v1/graph/widget/{id}/{widgetId}
resource "aws_api_gateway_resource" "graph_widget_dataset_id_widget_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_widget_id_resource.id
  path_part   = "{widgetId}"
}

// /api/v1/graph/layer
resource "aws_api_gateway_resource" "graph_layer_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_resource.id
  path_part   = "layer"
}

// /api/v1/graph/layer/{id}
resource "aws_api_gateway_resource" "graph_layer_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_layer_resource.id
  path_part   = "{id}"
}

// /api/v1/graph/layer/{id}/{layerId}
resource "aws_api_gateway_resource" "graph_layer_dataset_id_layer_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_layer_id_resource.id
  path_part   = "{layerId}"
}

// /api/v1/graph/metadata
resource "aws_api_gateway_resource" "graph_metadata_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_resource.id
  path_part   = "metadata"
}

// /api/v1/graph/metadata/{resourceTypeOrMetadataId}
resource "aws_api_gateway_resource" "graph_metadata_resource_type_or_metadata_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_metadata_resource.id
  path_part   = "{resourceTypeOrId}"
}

// /api/v1/graph/metadata/{resourceTypeOrMetadataId}/{resourceId}
resource "aws_api_gateway_resource" "graph_metadata_resource_type_or_metadata_id_resource_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_metadata_resource_type_or_metadata_id_resource.id
  path_part   = "{resourceId}"
}

// /api/v1/graph/metadata/{resourceTypeOrMetadataId}/{resourceId}/{metadataId}
resource "aws_api_gateway_resource" "graph_metadata_resource_type_or_metadata_id_resource_id_metadata_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_metadata_resource_type_or_metadata_id_resource_id_resource.id
  path_part   = "{metadataId}"
}

// /api/v1/graph/favourite
resource "aws_api_gateway_resource" "graph_favourite_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_resource.id
  path_part   = "favourite"
}

// /api/v1/graph/favourite/{resourceType}
resource "aws_api_gateway_resource" "graph_favourite_resource_type_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_favourite_resource.id
  path_part   = "{resourceType}"
}

// /api/v1/graph/favourite/{resourceType}/{resourceId}
resource "aws_api_gateway_resource" "graph_favourite_resource_type_resource_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_favourite_resource_type_resource.id
  path_part   = "{resourceId}"
}

// /api/v1/graph/favourite/{resourceType}/{resourceId}/{userId}
resource "aws_api_gateway_resource" "graph_favourite_resource_type_resource_id_user_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_favourite_resource_type_resource_id_resource.id
  path_part   = "{userId}"
}

// /api/v1/graph/{resourceType}
resource "aws_api_gateway_resource" "graph_resource_type_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_resource.id
  path_part   = "{resourceType}"
}

// /api/v1/graph/{resourceType}/{resourceId}
resource "aws_api_gateway_resource" "graph_resource_type_resource_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_resource_type_resource.id
  path_part   = "{resourceId}"
}

// /api/v1/graph/{resourceType}/{resourceId}/associate
resource "aws_api_gateway_resource" "graph_resource_type_resource_id_associate_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_resource_type_resource_id_resource.id
  path_part   = "associate"
}

// /api/v1/graph/query/similar-dataset
resource "aws_api_gateway_resource" "graph_query_similar_dataset_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_resource.id
  path_part   = "similar-dataset"
}

// /api/v1/graph/query/similar-dataset/{datasetId}
resource "aws_api_gateway_resource" "graph_query_similar_dataset_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_similar_dataset_resource.id
  path_part   = "{datasetId}"
}

// /api/v1/graph/query/list-concepts
resource "aws_api_gateway_resource" "graph_query_list_concepts_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_resource.id
  path_part   = "list-concepts"
}

// /api/v1/graph/query/list-concepts/{datasetId}
resource "aws_api_gateway_resource" "graph_query_list_concepts_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_list_concepts_resource.id
  path_part   = "{datasetId}"
}

// /api/v1/graph/query/concepts-inferred
resource "aws_api_gateway_resource" "graph_query_concepts_inferred_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_resource.id
  path_part   = "concepts-inferred"
}

// /api/v1/graph/query/concepts-ancestors
resource "aws_api_gateway_resource" "graph_query_concepts_ancestors_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_resource.id
  path_part   = "concepts-ancestors"
}

// /api/v1/graph/query/similar-dataset-including-descendent
resource "aws_api_gateway_resource" "graph_query_similar_dataset_including_descendent_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_resource.id
  path_part   = "similar-dataset-including-descendent"
}

// /api/v1/graph/query/similar-dataset-including-descendent/{datasetId}
resource "aws_api_gateway_resource" "graph_query_similar_dataset_including_descendent_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_similar_dataset_including_descendent_resource.id
  path_part   = "{datasetId}"
}

// /api/v1/graph/query/search-datasets
resource "aws_api_gateway_resource" "graph_query_search_datasets_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_resource.id
  path_part   = "search-datasets"
}

// /api/v1/graph/query/search-datasets-ids
resource "aws_api_gateway_resource" "graph_query_search_datasets_ids_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_resource.id
  path_part   = "search-datasets-ids"
}

// /api/v1/graph/query/most-liked-datasets
resource "aws_api_gateway_resource" "graph_query_most_liked_datasets_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_resource.id
  path_part   = "most-liked-datasets"
}

// /api/v1/graph/query/most-viewed
resource "aws_api_gateway_resource" "graph_query_most_viewed_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_resource.id
  path_part   = "most-viewed"
}

// /api/v1/graph/query/most-viewed-by-user
resource "aws_api_gateway_resource" "graph_query_most_viewed_by_user_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_resource.id
  path_part   = "most-viewed-by-user"
}

// /api/v1/graph/query/search-by-label-synonyms
resource "aws_api_gateway_resource" "graph_query_search_by_label_synonyms_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_query_resource.id
  path_part   = "search-by-label-synonyms"
}

// /api/v1/graph/find-by-ids
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
  uri          = "http://api.resourcewatch.org/api/v1/graph/query"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_post_graph_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_dataset_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/graph/dataset/{datasetId}"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_post_graph_dataset_id_visited" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_dataset_id_visited_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/graph/dataset/{datasetId}/visited"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_post_graph_widget_dataset_id_widget_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_widget_dataset_id_widget_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/graph/widget/{datasetId}/{widgetId}"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_post_graph_layer_dataset_id_layer_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_layer_dataset_id_layer_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/graph/layer/{datasetId}/{layerId}"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_post_graph_metadata_resource_type_or_metadata_id_resource_id_metadata_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_metadata_resource_type_or_metadata_id_resource_id_metadata_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/graph/metadata/{resourceTypeOrMetadataId}/{resourceId}/{metadataId}"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_post_graph_favourite_resource_type_resource_id_user_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_favourite_resource_type_resource_id_user_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/graph/favourite/{resourceType}/{resourceId}/{userId}"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_post_graph_resource_type_resource_id_associate" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_resource_type_resource_id_associate_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/graph/{resourceType}/{resourceId}/associate"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_put_graph_resource_type_resource_id_associate" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_resource_type_resource_id_associate_resource
  method       = "PUT"
  uri          = "http://api.resourcewatch.org/api/v1/graph/{resourceType}/{resourceId}/associate"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_delete_graph_resource_type_resource_id_associate" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_resource_type_resource_id_associate_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/graph/{resourceType}/{resourceId}/associate"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_delete_graph_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_dataset_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/graph/dataset/{datasetId}"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_delete_graph_widget_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_widget_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/graph/widget/{widgetId}"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_delete_graph_layer_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_layer_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/graph/layer/{layerId}"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_delete_graph_metadata_resource_type_or_metadata_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_metadata_resource_type_or_metadata_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/graph/metadata/{resourceTypeOrMetadataId}"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_delete_graph_favourite_resource_type_resource_id_user_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_favourite_resource_type_resource_id_user_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/graph/favourite/{resourceType}/{resourceId}/{userId}"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_get_graph_query_similar_dataset" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_similar_dataset_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/graph/query/similar-dataset"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_get_graph_query_similar_dataset_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_similar_dataset_dataset_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/graph/query/similar-dataset/{datasetId}"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_get_graph_query_list_concepts" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_list_concepts_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/graph/query/list-concepts"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_get_graph_query_concepts_inferred" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_concepts_inferred_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/graph/query/concepts-inferred"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_post_graph_query_concepts_inferred" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_concepts_inferred_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/graph/query/concepts-inferred"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_get_graph_query_concepts_ancestors" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_concepts_ancestors_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/graph/query/concepts-ancestors"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_post_graph_query_concepts_ancestors" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_concepts_ancestors_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/graph/query/concepts-ancestors"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_get_graph_query_similar_dataset_including_descendent" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_similar_dataset_including_descendent_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/graph/query/similar-dataset-including-descendent"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_get_graph_query_similar_dataset_including_descendent_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_similar_dataset_including_descendent_dataset_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/graph/query/similar-dataset-including-descendent/{datasetId}"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_get_graph_graph_query_search_datasets" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_search_datasets_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/graph/query/search-datasets"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_get_graph_graph_query_search_datasets_ids" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_search_datasets_ids_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/graph/query/search-datasets-ids"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_get_graph_graph_query_most_liked_datasets" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_most_liked_datasets_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/graph/query/most-liked-datasets"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_post_graph_query_search_datasets" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_search_datasets_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/graph/query/search-datasets"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_get_graph_query_most_viewed" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_most_viewed_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/graph/query/most-viewed"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_get_graph_query_most_viewed_by_user" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_most_viewed_by_user_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/graph/query/most-viewed-by-user"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_get_graph_query_search_by_label_synonyms" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_search_by_label_synonyms_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/graph/query/search-by-label-synonyms"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_get_graph_query_list_concepts_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_list_concepts_dataset_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/graph/query/list-concepts/{datasetId}"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}

module "graph_client_post_graph_find_by_ids" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/graph/query/list-concepts/find-by-ids"
  vpc_link     = aws_api_gateway_vpc_link.graph_client_lb_vpc_link
}