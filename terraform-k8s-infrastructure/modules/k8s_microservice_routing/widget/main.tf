
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

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/"
}

// /v1/dataset/{datasetId}
data "aws_api_gateway_resource" "dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/dataset/{datasetId}"
}

// /v1/widget
resource "aws_api_gateway_resource" "widget_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "widget"
}

// /v1/widget/find-by-ids
resource "aws_api_gateway_resource" "widget_find_by_ids_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.widget_resource.id
  path_part   = "find-by-ids"
}

// /v1/widget/change-environment
resource "aws_api_gateway_resource" "widget_change_environment_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.widget_resource.id
  path_part   = "change-environment"
}

// /v1/widget/{widgetId}
resource "aws_api_gateway_resource" "widget_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.widget_resource.id
  path_part   = "{widgetId}"
}

// /v1/widget/change-environment/{datasetId}
resource "aws_api_gateway_resource" "widget_change_environment_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.widget_change_environment_resource.id
  path_part   = "{datasetId}"
}

// /v1/widget/change-environment/{datasetId}/{env}
resource "aws_api_gateway_resource" "widget_env_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.widget_change_environment_dataset_id_resource.id
  path_part   = "{env}"
}

// /v1/dataset/{datasetId}/widget
resource "aws_api_gateway_resource" "dataset_id_widget_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.dataset_id_resource.id
  path_part   = "widget"
}

// /v1/dataset/{datasetId}/widget/{widgetId}
resource "aws_api_gateway_resource" "dataset_id_widget_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_widget_resource.id
  path_part   = "{widgetId}"
}

// /v1/widget/{widgetId}/clone
resource "aws_api_gateway_resource" "widget_clone_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.widget_id_resource.id
  path_part   = "clone"
}

// /v1/dataset/{datasetId}/widget/{widgetId}/clone
resource "aws_api_gateway_resource" "dataset_id_widget_id_clone_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_widget_id_resource.id
  path_part   = "clone"
}

module "widget_get_widget" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.widget_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/widget"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_get_dataset_id_widget" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_get_dataset_id_widget_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget/{widgetId}"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_get_widget_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.widget_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/widget/{widgetId}"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_post_dataset_id_widget" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_post_widget" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.widget_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/widget"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_patch_widget_id" {
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

module "widget_delete_dataset_id_widget" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_patch_dataset_id_widget_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget/{widgetId}"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_patch_widget_change_environment_dataset_id_env" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.widget_env_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org/api/v1/widget/change-environment/{datasetId}/{env}"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_delete_dataset_id_widget_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget/{widgetId}"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_post_widget_find_by_ids" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.widget_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/widget/find-by-ids"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_post_dataset_id_clone" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.widget_clone_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/clone"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}

module "widget_post_dataset_id_widget_id_clone" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_clone_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{datasetId}/widget/{widgetId}/clone"
  vpc_link     = aws_api_gateway_vpc_link.widget_lb_vpc_link
}