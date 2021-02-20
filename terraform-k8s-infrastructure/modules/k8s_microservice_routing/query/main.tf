
resource "kubernetes_service" "query_service" {
  metadata {
    name      = "query"
    namespace = "default"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                 = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=query"
    }
  }
  spec {
    selector = {
      name = "query"
    }
    port {
      port        = 80
      target_port = 5000
    }

    type = "LoadBalancer"
  }
}

data "aws_lb" "query_lb" {
  name = split("-", kubernetes_service.query_service.status.0.load_balancer.0.ingress.0.hostname).0

  depends_on = [
    kubernetes_service.query_service
  ]
}

resource "aws_api_gateway_vpc_link" "query_lb_vpc_link" {
  name        = "Query LB VPC link"
  description = "VPC link to the query service load balancer"
  target_arns = [data.aws_lb.query_lb.arn]

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
resource "aws_api_gateway_resource" "query_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "query"
}

// /v1/download
resource "aws_api_gateway_resource" "download_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "download"
}

// /v1/jiminy
resource "aws_api_gateway_resource" "jiminy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "jiminy"
}

// /v1/fields
resource "aws_api_gateway_resource" "fields_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "fields"
}

// /v1/query/{datasetId}
resource "aws_api_gateway_resource" "query_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.query_resource.id
  path_part   = "{datasetId}"
}

// /v1/download/{datasetId}
resource "aws_api_gateway_resource" "download_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.download_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields/{datasetId}
resource "aws_api_gateway_resource" "fields_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.fields_resource.id
  path_part   = "{datasetId}"
}

module "query_get_query" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.query_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/query"
  vpc_link       = aws_api_gateway_vpc_link.query_lb_vpc_link
}

module "query_post_query" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.query_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/query"
  vpc_link     = aws_api_gateway_vpc_link.query_lb_vpc_link
}

module "query_get_query_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.query_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/query/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.query_lb_vpc_link
}

module "query_post_query_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.query_dataset_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/query/{datasetId}"
  vpc_link     = aws_api_gateway_vpc_link.query_lb_vpc_link
}

module "download_get_download" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.download_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/download"
  vpc_link       = aws_api_gateway_vpc_link.query_lb_vpc_link
}

module "download_post_download" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.download_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/download"
  vpc_link     = aws_api_gateway_vpc_link.query_lb_vpc_link
}

module "download_get_download_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.download_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/download/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.query_lb_vpc_link
}

module "download_post_download_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.download_dataset_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/download/{datasetId}"
  vpc_link     = aws_api_gateway_vpc_link.query_lb_vpc_link
}

module "jiminy_get_jiminy" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.jiminy_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/jiminy"
  vpc_link       = aws_api_gateway_vpc_link.query_lb_vpc_link
}

module "jiminy_post_jiminy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.jiminy_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/jiminy"
  vpc_link     = aws_api_gateway_vpc_link.query_lb_vpc_link
}

module "fields_get_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.fields_dataset_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/fields/{datasetId}"
  vpc_link     = aws_api_gateway_vpc_link.query_lb_vpc_link
}
