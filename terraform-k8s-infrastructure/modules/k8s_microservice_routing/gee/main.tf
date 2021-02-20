
resource "kubernetes_service" "gee_service" {
  metadata {
    name = "gee"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                 = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=gee"
    }
  }
  spec {
    selector = {
      name = "gee"
    }
    port {
      port        = 80
      target_port = 5700
    }

    type = "LoadBalancer"
  }
}

data "aws_lb" "gee_lb" {
  name = split("-", kubernetes_service.gee_service.status.0.load_balancer.0.ingress.0.hostname).0

  depends_on = [
    kubernetes_service.gee_service
  ]
}

resource "aws_api_gateway_vpc_link" "gee_lb_vpc_link" {
  name        = "GEE LB VPC link"
  description = "VPC link to the gee service load balancer"
  target_arns = [data.aws_lb.gee_lb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

// /v1/query
data "aws_api_gateway_resource" "query_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/query"
}

// /v1/download
data "aws_api_gateway_resource" "download_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/download"
}

// /v1/fields
data "aws_api_gateway_resource" "fields_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/fields"
}

// /v1/rest-datasets
data "aws_api_gateway_resource" "rest_datasets_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/rest-datasets"
}

// /v1/query/gee
resource "aws_api_gateway_resource" "query_gee_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.query_resource.id
  path_part   = "gee"
}

// /v1/query/gee/{datasetId}
resource "aws_api_gateway_resource" "query_gee_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.query_gee_resource.id
  path_part   = "{datasetId}"
}

// /v1/download/gee
resource "aws_api_gateway_resource" "download_gee_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.download_resource.id
  path_part   = "gee"
}

// /v1/download/gee/{datasetId}
resource "aws_api_gateway_resource" "download_gee_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.download_gee_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields/gee
resource "aws_api_gateway_resource" "fields_gee_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.fields_resource.id
  path_part   = "gee"
}

// /v1/fields/gee/{datasetId}
resource "aws_api_gateway_resource" "fields_gee_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.fields_gee_resource.id
  path_part   = "{datasetId}"
}

// /v1/rest-datasets/gee
resource "aws_api_gateway_resource" "rest_datasets_gee_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.rest_datasets_resource.id
  path_part   = "gee"
}

// /v1/rest-datasets/gee/{datasetId}
resource "aws_api_gateway_resource" "rest_datasets_gee_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.rest_datasets_gee_resource.id
  path_part   = "{datasetId}"
}

module "gee_get_query_gee_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.query_gee_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/earthengine/query/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.gee_lb_vpc_link
}

module "gee_post_query_gee_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.query_gee_dataset_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/earthengine/query/{datasetId}"
  vpc_link     = aws_api_gateway_vpc_link.gee_lb_vpc_link
}

module "gee_get_download_gee_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.download_gee_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/earthengine/download/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.gee_lb_vpc_link
}

module "gee_post_download_gee_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.download_gee_dataset_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/earthengine/download/{datasetId}"
  vpc_link     = aws_api_gateway_vpc_link.gee_lb_vpc_link
}

module "gee_get_fields_gee_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.fields_gee_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/earthengine/fields/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.gee_lb_vpc_link
}

module "gee_get_rest_datasets_gee" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.rest_datasets_gee_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/earthengine/rest-datasets/gee"
  vpc_link     = aws_api_gateway_vpc_link.gee_lb_vpc_link
}

module "gee_delete_rest_datasets_gee_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.rest_datasets_gee_dataset_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/earthengine/rest-datasets/gee/{datasetId}"
  vpc_link     = aws_api_gateway_vpc_link.gee_lb_vpc_link
}
