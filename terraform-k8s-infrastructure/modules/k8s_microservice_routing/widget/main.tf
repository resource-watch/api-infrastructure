resource "kubernetes_service" "widget_service" {
  metadata {
    name      = "widget"
    namespace = "default"

  }
  spec {
    selector = {
      name = "widget"
    }
    port {
      port        = 30567
      node_port   = 30567
      target_port = 3050
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "widget_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30567
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.widget_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "widget_lb_target_group" {
  name        = "widget-lb-tg"
  port        = 30567
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_widget" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.widget_lb_target_group.arn
}

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
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
  uri          = "http://api.resourcewatch.org:30567/api/v1/widget"
  vpc_link     = var.vpc_link
}

module "widget_get_dataset_id_widget" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30567/api/v1/dataset/{datasetId}/widget"
  vpc_link     = var.vpc_link
}

module "widget_get_dataset_id_widget_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30567/api/v1/dataset/{datasetId}/widget/{widgetId}"
  vpc_link     = var.vpc_link
}

module "widget_get_widget_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.widget_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30567/api/v1/widget/{widgetId}"
  vpc_link     = var.vpc_link
}

module "widget_post_dataset_id_widget" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30567/api/v1/dataset/{datasetId}/widget"
  vpc_link     = var.vpc_link
}

module "widget_post_widget" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.widget_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30567/api/v1/widget"
  vpc_link     = var.vpc_link
}

module "widget_patch_widget_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.widget_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org:30567/api/v1/widget/{widgetId}"
  vpc_link     = var.vpc_link
}

module "widget_delete_by_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.widget_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30567/api/v1/widget/{widgetId}"
  vpc_link     = var.vpc_link
}

module "widget_delete_dataset_id_widget" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30567/api/v1/dataset/{datasetId}/widget"
  vpc_link     = var.vpc_link
}

module "widget_patch_dataset_id_widget_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org:30567/api/v1/dataset/{datasetId}/widget/{widgetId}"
  vpc_link     = var.vpc_link
}

module "widget_patch_widget_change_environment_dataset_id_env" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.widget_env_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org:30567/api/v1/widget/change-environment/{datasetId}/{env}"
  vpc_link     = var.vpc_link
}

module "widget_delete_dataset_id_widget_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30567/api/v1/dataset/{datasetId}/widget/{widgetId}"
  vpc_link     = var.vpc_link
}

module "widget_post_widget_find_by_ids" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.widget_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30567/api/v1/widget/find-by-ids"
  vpc_link     = var.vpc_link
}

module "widget_post_dataset_id_clone" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.widget_clone_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30567/api/v1/dataset/{datasetId}/clone"
  vpc_link     = var.vpc_link
}

module "widget_post_dataset_id_widget_id_clone" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_widget_id_clone_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30567/api/v1/dataset/{datasetId}/widget/{widgetId}/clone"
  vpc_link     = var.vpc_link
}