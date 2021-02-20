
resource "kubernetes_service" "dataset_service" {
  metadata {
    name      = "dataset"
    namespace = "default"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                 = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=dataset"
    }
  }
  spec {
    selector = {
      name = "dataset"
    }
    port {
      port        = 80
      target_port = 3000
    }

    type = "LoadBalancer"
  }
}

data "aws_lb" "dataset_lb" {
  name = split("-", kubernetes_service.dataset_service.status.0.load_balancer.0.ingress.0.hostname).0

  depends_on = [
    kubernetes_service.dataset_service
  ]
}

resource "aws_api_gateway_vpc_link" "dataset_lb_vpc_link" {
  name        = "Dataset LB VPC link"
  description = "VPC link to the Dataset service load balancer"
  target_arns = [data.aws_lb.dataset_lb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v1/dataset
resource "aws_api_gateway_resource" "dataset_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "dataset"
}

// /v1/rest-datasets
resource "aws_api_gateway_resource" "rest_datasets_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "rest-datasets"
}

// /v1/dataset/{datasetId}
resource "aws_api_gateway_resource" "dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_resource.id
  path_part   = "{datasetId}"
}

// /v1/dataset/find-by-ids
resource "aws_api_gateway_resource" "dataset_find_by_ids_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_resource.id
  path_part   = "find-by-ids"
}

// /v1/dataset/upload
resource "aws_api_gateway_resource" "dataset_upload_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_resource.id
  path_part   = "upload"
}

// /v1/dataset/{datasetId}/clone
resource "aws_api_gateway_resource" "dataset_clone_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_resource.id
  path_part   = "clone"
}

// /v1/dataset/{datasetId}/flush
resource "aws_api_gateway_resource" "dataset_flush_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_resource.id
  path_part   = "flush"
}

// /v1/dataset/{datasetId}/recover
resource "aws_api_gateway_resource" "dataset_recover_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_resource.id
  path_part   = "recover"
}

// /v1/dataset/{datasetId}/lastUpdated
resource "aws_api_gateway_resource" "dataset_last_updated_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_resource.id
  path_part   = "lastUpdated"
}

module "dataset_get_dataset" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/dataset"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}

module "dataset_get_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}

module "dataset_update_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}

module "dataset_delete_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}

module "dataset_post_dataset" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}

module "dataset_post_dataset_id_clone" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_clone_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/clone"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}

module "dataset_post_dataset_id_flush" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_flush_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/flush"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}

module "dataset_post_dataset_id_recover" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_recover_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/recover"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}

module "dataset_get_dataset_id_last_updated" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_last_updated_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/lastUpdated"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}

module "dataset_post_dataset_find_by_ids" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/find-by-ids"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}

module "dataset_post_dataset_upload" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_upload_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/upload"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}
