provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

resource "kubernetes_service" "widget_service" {
  metadata {
    name      = "widget"
    namespace = "default"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                 = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=widget"
    }
  }
  spec {
    selector = {
      name = "widget"
    }
    port {
      port        = 80
      target_port = 3050
    }

    type = "LoadBalancer"
  }
}

data "aws_lb" "widget_lb" {
  name = split("-", kubernetes_service.widget_service.status.0.load_balancer.0.ingress.0.hostname).0

  depends_on = [
    kubernetes_service.widget_service
  ]
}

resource "aws_api_gateway_vpc_link" "widget_lb_vpc_link" {
  name        = "Widget LB VPC link"
  description = "VPC link to the widget service load balancer"
  target_arns = [data.aws_lb.widget_lb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_resource" "widget_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.resource_root_id
  path_part   = "widget"
}

resource "aws_api_gateway_resource" "widget_find_by_ids_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.widget_resource.id
  path_part   = "find-by-ids"
}

resource "aws_api_gateway_resource" "widget_change_environment_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.widget_resource.id
  path_part   = "change-environment"
}

resource "aws_api_gateway_resource" "widget_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.widget_resource.id
  path_part   = "{widgetId}"
}

resource "aws_api_gateway_resource" "widget_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.widget_change_environment_resource.id
  path_part   = "{datasetId}"
}

resource "aws_api_gateway_resource" "widget_env_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.widget_dataset_id_resource.id
  path_part   = "{env}"
}

resource "aws_api_gateway_resource" "dataset_id_widget_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.dataset_id_resource.id
  path_part   = "widget"
}

resource "aws_api_gateway_resource" "dataset_id_widget_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_widget_resource.id
  path_part   = "{widgetId}"
}

resource "aws_api_gateway_resource" "widget_clone_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.widget_id_resource.id
  path_part   = "clone"
}

resource "aws_api_gateway_resource" "dataset_id_widget_id_clone_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_widget_id_resource.id
  path_part   = "clone"
}

module "widget_get" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.widget_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/widget"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_get_for_dataset" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_get_for_dataset_by_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget/{widgetId}"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_get_by_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.widget_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/widget/{widgetId}"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_post_for_dataset" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_post" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.widget_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/widget"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_patch_by_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.widget_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org/api/v1/widget/{widgetId}"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_delete_by_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.widget_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/widget/{widgetId}"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_delete_for_dataset" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_patch_for_dataset_by_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget/{widgetId}"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_change_environment_for_dataset_by_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.widget_env_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org/api/v1/widget/change-environment/{datasetId}/{env}"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_delete_for_dataset_by_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget/{widgetId}"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_post_find_by_ids" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.widget_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/widget/find-by-ids"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_clone" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.widget_clone_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/clone"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_clone_for_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_clone_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget/{widgetId}/clone"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}