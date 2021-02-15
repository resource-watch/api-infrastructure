provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

resource "kubernetes_service" "doc_swagger_service" {
  metadata {
    name      = "doc-swagger"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                 = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=doc-swagger"
    }
  }
  spec {
    selector = {
      name = "doc-swagger"
    }
    port {
      port        = 80
      target_port = 3500
    }

    type = "LoadBalancer"
  }
}

data "aws_lb" "doc_swagger_lb" {
  name = split("-", kubernetes_service.doc_swagger_service.status.0.load_balancer.0.ingress.0.hostname).0

  depends_on = [
    kubernetes_service.doc_swagger_service
  ]
}

resource "aws_api_gateway_vpc_link" "doc_swagger_lb_vpc_link" {
  name        = "Doc swagger LB VPC link"
  description = "VPC link to the doc-swagger service load balancer"
  target_arns = [data.aws_lb.doc_swagger_lb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

//  /documentation
resource "aws_api_gateway_resource" "documentation_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.resource_root_id
  path_part   = "documentation"
}

resource "aws_api_gateway_resource" "documentation_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.documentation_resource.id
  path_part   = "{proxy+}"
}

module "doc_swagger_any" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.documentation_resource
  method       = "ANY"
  uri          = "http://api.resourcewatch.org/documentation"
  vpc_link     = aws_api_gateway_vpc_link.doc_swagger_lb_vpc_link
}

module "doc_swagger_proxy_any" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.documentation_proxy_resource
  method       = "ANY"
  uri          = "http://api.resourcewatch.org/documentation/{proxy}"
  vpc_link     = aws_api_gateway_vpc_link.doc_swagger_lb_vpc_link
}