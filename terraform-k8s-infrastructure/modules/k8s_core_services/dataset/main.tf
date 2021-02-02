provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

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
      name      = "dataset"
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
}

resource "aws_api_gateway_vpc_link" "dataset_lb_vpc_link" {
  name        = "Dataset LB VPC link"
  description = "VPC link to the Dataset service load balancer"
  target_arns = [data.aws_lb.dataset_lb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_resource" "dataset_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.resource_root.id
  path_part   = "dataset"
}

resource "aws_api_gateway_resource" "dataset_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_resource.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_resource" "dataset_find_by_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_resource.id
  path_part   = "find-by-id"
}

resource "aws_api_gateway_resource" "dataset_upload_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_resource.id
  path_part   = "upload"
}

module "dataset_get" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/dataset"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}

module "dataset_get_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_proxy_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{proxy}"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}

module "dataset_post" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}

module "dataset_post_find_by_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_find_by_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/find-by-id"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}

module "dataset_post_upload" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_upload_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/upload"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}

module "dataset_patch_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_proxy_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{proxy}"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}

module "dataset_delete_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_proxy_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{proxy}"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}