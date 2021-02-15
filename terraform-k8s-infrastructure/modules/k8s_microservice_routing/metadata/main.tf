provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

resource "kubernetes_service" "metadata_service" {
  metadata {
    name      = "metadata"
    namespace = "default"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                 = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=metadata"
    }
  }
  spec {
    selector = {
      name = "metadata"
    }
    port {
      port        = 80
      target_port = 4000
    }

    type = "LoadBalancer"
  }
}

data "aws_lb" "metadata_lb" {
  name = split("-", kubernetes_service.metadata_service.status.0.load_balancer.0.ingress.0.hostname).0

  depends_on = [
    kubernetes_service.metadata_service
  ]
}

resource "aws_api_gateway_vpc_link" "metadata_lb_vpc_link" {
  name        = "Metadata LB VPC link"
  description = "VPC link to the metadata service load balancer"
  target_arns = [data.aws_lb.metadata_lb.arn]

  lifecycle {
    create_before_destroy = true
  }
}


data "aws_api_gateway_resource" "dataset_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/dataset"
}

data "aws_api_gateway_resource" "dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/dataset/{datasetId}"
}

data "aws_api_gateway_resource" "metadata_dataset_id_widget_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/dataset/{datasetId}/widget"
}

data "aws_api_gateway_resource" "metadata_dataset_id_widget_id_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/dataset/{datasetId}/widget/{widgetId}"
}

data "aws_api_gateway_resource" "metadata_dataset_id_layer_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/dataset/{datasetId}/layer"
}

data "aws_api_gateway_resource" "metadata_dataset_id_layer_id_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/dataset/{datasetId}/layer/{layerId}"
}

// /api/v1/metadata
resource "aws_api_gateway_resource" "metadata_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.resource_root_id
  path_part   = "metadata"
}

// /api/v1/dataset/metadata
resource "aws_api_gateway_resource" "metadata_dataset_metadata_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.dataset_resource.id
  path_part   = "metadata"
}

// /api/v1/dataset/metadata/find-by-ids
resource "aws_api_gateway_resource" "metadata_dataset_metadata_find_by_ids_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.metadata_dataset_metadata_resource.id
  path_part   = "find-by-ids"
}

// /api/v1/dataset/{datasetId}/metadata
resource "aws_api_gateway_resource" "metadata_dataset_id_metadata_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.dataset_id_resource.id
  path_part   = "metadata"
}

// /api/v1/dataset/{datasetId}/metadata/clone
resource "aws_api_gateway_resource" "metadata_dataset_metadata_clone_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.metadata_dataset_id_metadata_resource.id
  path_part   = "clone"
}

// /api/v1/dataset/{datasetId}/widget/metadata
resource "aws_api_gateway_resource" "metadata_dataset_id_widget_metadata_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.metadata_dataset_id_widget_resource.id
  path_part   = "metadata"
}

// /api/v1/dataset/{datasetId}/widget/metadata/find-by-ids
resource "aws_api_gateway_resource" "metadata_dataset_id_widget_metadata_find_by_ids_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.metadata_dataset_id_widget_metadata_resource.id
  path_part   = "find-by-ids"
}

// /api/v1/dataset/{datasetId}/widget/{widgetId}/metadata
resource "aws_api_gateway_resource" "metadata_dataset_id_widget_id_metadata_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.metadata_dataset_id_widget_id_resource.id
  path_part   = "metadata"
}

// /api/v1/dataset/{datasetId}/layer/metadata
resource "aws_api_gateway_resource" "metadata_dataset_id_layer_metadata_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.metadata_dataset_id_layer_resource.id
  path_part   = "metadata"
}

// /api/v1/dataset/{datasetId}/layer/metadata/find-by-ids
resource "aws_api_gateway_resource" "metadata_dataset_id_layer_metadata_find_by_ids_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.metadata_dataset_id_layer_metadata_resource.id
  path_part   = "find-by-ids"
}

// /api/v1/dataset/{datasetId}/layer/{layerId}/metadata
resource "aws_api_gateway_resource" "metadata_dataset_id_layer_id_metadata_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.metadata_dataset_id_layer_id_resource.id
  path_part   = "metadata"
}

module "metadata_get" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.metadata_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/metadata"
  vpc_link     = aws_api_gateway_vpc_link.metadata_lb_vpc_link
}

// Dataset
module "metadata_get_for_dataset" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.metadata_dataset_id_metadata_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/metadata"
  vpc_link     = aws_api_gateway_vpc_link.metadata_lb_vpc_link
}

module "metadata_post_for_dataset" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.metadata_dataset_id_metadata_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/metadata"
  vpc_link     = aws_api_gateway_vpc_link.metadata_lb_vpc_link
}

module "metadata_delete_for_dataset" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.metadata_dataset_id_metadata_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/metadata"
  vpc_link     = aws_api_gateway_vpc_link.metadata_lb_vpc_link
}

module "metadata_post_for_dataset_clone" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.metadata_dataset_metadata_clone_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/metadata/clone"
  vpc_link     = aws_api_gateway_vpc_link.metadata_lb_vpc_link
}

module "metadata_patch_for_dataset" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.metadata_dataset_id_metadata_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/metadata"
  vpc_link     = aws_api_gateway_vpc_link.metadata_lb_vpc_link
}

// Widget
module "metadata_get_for_dataset_widget" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.metadata_dataset_id_widget_id_metadata_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget/{widgetId}/metadata"
  vpc_link     = aws_api_gateway_vpc_link.metadata_lb_vpc_link
}

module "metadata_post_for_dataset_widget" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.metadata_dataset_id_widget_id_metadata_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget/{widgetId}/metadata"
  vpc_link     = aws_api_gateway_vpc_link.metadata_lb_vpc_link
}

module "metadata_delete_for_dataset_widget" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.metadata_dataset_id_widget_id_metadata_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget/{widgetId}/metadata"
  vpc_link     = aws_api_gateway_vpc_link.metadata_lb_vpc_link
}

module "metadata_patch_for_dataset_widget" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.metadata_dataset_id_widget_id_metadata_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget/{widgetId}/metadata"
  vpc_link     = aws_api_gateway_vpc_link.metadata_lb_vpc_link
}

// Layer
module "metadata_get_for_dataset_layer" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.metadata_dataset_id_layer_id_metadata_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/layer/{layerId}/metadata"
  vpc_link     = aws_api_gateway_vpc_link.metadata_lb_vpc_link
}

module "metadata_post_for_dataset_layer" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.metadata_dataset_id_layer_id_metadata_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/layer/{layerId}/metadata"
  vpc_link     = aws_api_gateway_vpc_link.metadata_lb_vpc_link
}

module "metadata_delete_for_dataset_layer" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.metadata_dataset_id_layer_id_metadata_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/layer/{layerId}/metadata"
  vpc_link     = aws_api_gateway_vpc_link.metadata_lb_vpc_link
}

module "metadata_patch_for_dataset_layer" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.metadata_dataset_id_layer_id_metadata_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/layer/{layerId}/metadata"
  vpc_link     = aws_api_gateway_vpc_link.metadata_lb_vpc_link
}

// Find by ids
module "metadata_dataset_post_find_by_ids" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.metadata_dataset_metadata_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/metadata/find-by-ids"
  vpc_link     = aws_api_gateway_vpc_link.metadata_lb_vpc_link
}

module "metadata_layer_post_find_by_ids" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.metadata_dataset_id_layer_metadata_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/layer/metadata/find-by-ids"
  vpc_link     = aws_api_gateway_vpc_link.metadata_lb_vpc_link
}

module "metadata_widget_post_find_by_ids" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.metadata_dataset_id_widget_metadata_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget/metadata/find-by-ids"
  vpc_link     = aws_api_gateway_vpc_link.metadata_lb_vpc_link
}
