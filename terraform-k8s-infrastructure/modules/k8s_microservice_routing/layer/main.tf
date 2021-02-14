provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

resource "kubernetes_service" "layer_service" {
  metadata {
    name      = "layer"
    namespace = "default"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                 = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=layer"
    }
  }
  spec {
    selector = {
      name = "layer"
    }
    port {
      port        = 80
      target_port = 6000
    }

    type = "LoadBalancer"
  }
}

data "aws_lb" "layer_lb" {
  name = split("-", kubernetes_service.layer_service.status.0.load_balancer.0.ingress.0.hostname).0

  depends_on = [
    kubernetes_service.layer_service
  ]
}

resource "aws_api_gateway_vpc_link" "layer_lb_vpc_link" {
  name        = "Layer LB VPC link"
  description = "VPC link to the layer service load balancer"
  target_arns = [data.aws_lb.layer_lb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_api_gateway_resource" "dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/dataset/{datasetId}"
}

resource "aws_api_gateway_resource" "layer_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.resource_root_id
  path_part   = "layer"
}

resource "aws_api_gateway_resource" "layer_find_by_ids_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.layer_resource.id
  path_part   = "find-by-ids"
}

resource "aws_api_gateway_resource" "layer_change_environment_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.layer_resource.id
  path_part   = "change-environment"
}

resource "aws_api_gateway_resource" "layer_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.layer_resource.id
  path_part   = "{layerId}"
}

resource "aws_api_gateway_resource" "layer_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.layer_change_environment_resource.id
  path_part   = "{datasetId}"
}

resource "aws_api_gateway_resource" "layer_env_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.layer_dataset_id_resource.id
  path_part   = "{env}"
}

resource "aws_api_gateway_resource" "dataset_id_layer_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.dataset_id_resource.id
  path_part   = "layer"
}

resource "aws_api_gateway_resource" "dataset_id_layer_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_layer_resource.id
  path_part   = "{layerId}"
}

resource "aws_api_gateway_resource" "layer_id_expire_cache_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.layer_id_resource.id
  path_part   = "expire-cache"
}

module "layer_get" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.layer_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/layer"
  vpc_link     = aws_api_gateway_vpc_link.layer_lb_vpc_link
}

module "layer_get_for_dataset" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_layer_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/layer"
  vpc_link     = aws_api_gateway_vpc_link.layer_lb_vpc_link
}

module "layer_get_for_dataset_by_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_layer_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/layer/{layerId}"
  vpc_link     = aws_api_gateway_vpc_link.layer_lb_vpc_link
}

module "layer_get_by_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.layer_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/layer/{layerId}"
  vpc_link     = aws_api_gateway_vpc_link.layer_lb_vpc_link
}

module "layer_post_for_dataset" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_layer_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/layer"
  vpc_link     = aws_api_gateway_vpc_link.layer_lb_vpc_link
}

module "layer_delete_for_dataset" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_layer_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/layer"
  vpc_link     = aws_api_gateway_vpc_link.layer_lb_vpc_link
}

module "layer_patch_for_dataset_by_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_layer_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/layer/{layerId}"
  vpc_link     = aws_api_gateway_vpc_link.layer_lb_vpc_link
}

module "layer_change_environment_for_dataset_by_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.layer_env_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org/api/v1/layer/change-environment/{datasetId}/{env}"
  vpc_link     = aws_api_gateway_vpc_link.layer_lb_vpc_link
}

module "layer_delete_for_dataset_by_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_layer_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/layer/{layerId}"
  vpc_link     = aws_api_gateway_vpc_link.layer_lb_vpc_link
}

module "layer_post_find_by_ids" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.layer_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/layer/find-by-ids"
  vpc_link     = aws_api_gateway_vpc_link.layer_lb_vpc_link
}

module "layer_expire_cache" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.layer_id_expire_cache_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/layer/{layerId}/expire-cache"
  vpc_link     = aws_api_gateway_vpc_link.layer_lb_vpc_link
}