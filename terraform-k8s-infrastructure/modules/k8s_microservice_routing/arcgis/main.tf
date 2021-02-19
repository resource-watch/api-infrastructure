provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

resource "kubernetes_service" "arcgis_service" {
  metadata {
    name      = "arcgis"
    namespace = "default"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                 = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=arcgis"
    }
  }
  spec {
    selector = {
      name = "arcgis"
    }
    port {
      port        = 80
      target_port = 4100
    }

    type = "LoadBalancer"
  }
}

data "aws_lb" "arcgis_lb" {
  name = split("-", kubernetes_service.arcgis_service.status.0.load_balancer.0.ingress.0.hostname).0

  depends_on = [
    kubernetes_service.arcgis_service
  ]
}

resource "aws_api_gateway_vpc_link" "arcgis_lb_vpc_link" {
  name        = "Arcgis LB VPC link"
  description = "VPC link to the arcgis service load balancer"
  target_arns = [data.aws_lb.arcgis_lb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v1/query
resource "aws_api_gateway_resource" "v1_query_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "query"
}

// /v1/query/featureservice
resource "aws_api_gateway_resource" "v1_query_featureservice_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_query_resource.id
  path_part   = "featureservice"
}

// /v1/query/featureservice/{datasetId}
resource "aws_api_gateway_resource" "v1_query_featureservice_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_query_featureservice_resource.id
  path_part   = "{datasetId}"
}

// /v1/download
resource "aws_api_gateway_resource" "v1_download_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "download"
}

// /v1/download/featureservice
resource "aws_api_gateway_resource" "v1_download_featureservice_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_download_resource.id
  path_part   = "featureservice"
}

// /v1/download/featureservice/{datasetId}
resource "aws_api_gateway_resource" "v1_download_featureservice_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_download_featureservice_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields
resource "aws_api_gateway_resource" "v1_fields_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "fields"
}

// /v1/fields/featureservice
resource "aws_api_gateway_resource" "v1_fields_featureservice_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_fields_resource.id
  path_part   = "featureservice"
}

// /v1/fields/featureservice/{datasetId}
resource "aws_api_gateway_resource" "v1_fields_featureservice_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_fields_featureservice_resource.id
  path_part   = "{datasetId}"
}

// /v1/rest-datasets
resource "aws_api_gateway_resource" "v1_rest_datasets_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "rest-datasets"
}

// /v1/rest-datasets/featureservice
resource "aws_api_gateway_resource" "v1_rest_datasets_featureservice_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_rest_datasets_resource.id
  path_part   = "featureservice"
}

// /v1/rest-datasets/featureservice/{datasetId}
resource "aws_api_gateway_resource" "v1_rest-datasets_featureservice_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_rest_datasets_featureservice_resource.id
  path_part   = "{datasetId}"
}

module "arcgis_get_v1_query_featureservice_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_query_featureservice_dataset_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/query/featureservice/{datasetId}"
  vpc_link     = aws_api_gateway_vpc_link.arcgis_lb_vpc_link
}

module "arcgis_post_v1_query_featureservice_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_query_featureservice_dataset_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/query/featureservice/{datasetId}"
  vpc_link     = aws_api_gateway_vpc_link.arcgis_lb_vpc_link
}

module "arcgis_get_v1_download_featureservice_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_download_featureservice_dataset_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/download/featureservice/{datasetId}"
  vpc_link     = aws_api_gateway_vpc_link.arcgis_lb_vpc_link
}

module "arcgis_post_v1_download_featureservice_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_download_featureservice_dataset_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/download/featureservice/{datasetId}"
  vpc_link     = aws_api_gateway_vpc_link.arcgis_lb_vpc_link
}

module "arcgis_post_v1_fields_featureservice_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_fields_featureservice_dataset_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/fields/featureservice/{datasetId}"
  vpc_link     = aws_api_gateway_vpc_link.arcgis_lb_vpc_link
}

module "arcgis_post_v1_rest_datasets_featureservice" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_rest_datasets_featureservice_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/rest-datasets/featureservice"
  vpc_link     = aws_api_gateway_vpc_link.arcgis_lb_vpc_link
}

module "arcgis_delete_v1_rest_datasets_featureservice_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_rest_datasets_featureservice_dataset_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/rest-datasets/featureservice/{datasetId}"
  vpc_link     = aws_api_gateway_vpc_link.arcgis_lb_vpc_link
}
