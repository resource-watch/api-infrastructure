provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

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

resource "aws_api_gateway_resource" "query_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.resource_root_id
  path_part   = "query"
}

resource "aws_api_gateway_resource" "query_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.query_resource.id
  path_part   = "{id}"
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

module "query_get_query_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.query_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/query/{id}"
  vpc_link       = aws_api_gateway_vpc_link.query_lb_vpc_link
}
