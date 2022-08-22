resource "kubernetes_service" "widget_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

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

locals {
  api_gateway_target_url = var.connection_type == "VPC_LINK" ? data.aws_lb.load_balancer[0].dns_name : var.target_url
}

data "aws_lb" "load_balancer" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "widget_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30567
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.widget_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "widget_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

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
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  lb_target_group_arn    = aws_lb_target_group.widget_lb_target_group[0].arn
}

// /v1/widget
module "widget_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "widget"
}

// /v1/widget/{proxy+}
module "widget_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.widget_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/dataset/{datasetId}/widget
module "dataset_id_widget_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_dataset_id_resource.id
  path_part   = "widget"
}

// /v1/dataset/{datasetId}/widget/{widgetId}
module "dataset_id_widget_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.dataset_id_widget_resource.aws_api_gateway_resource.id
  path_part   = "{widgetId}"
}

// /v1/dataset/{datasetId}/widget/{widgetId}/{proxy+}
module "dataset_id_widget_id_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.dataset_id_widget_id_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "widget_get_widget" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.widget_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30567/api/v1/widget"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "widget_post_widget" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.widget_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30567/api/v1/widget"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "widget_any_widget_proxy" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.widget_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30567/api/v1/widget/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "widget_any_dataset_id_widget" {
  source                      = "../../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_widget_resource.aws_api_gateway_resource
  method                      = "ANY"
  uri                         = "http://${local.api_gateway_target_url}:30567/api/v1/dataset/{datasetId}/widget"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId"]
}

module "widget_any_dataset_id_widget_id" {
  source                      = "../../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_widget_id_resource.aws_api_gateway_resource
  method                      = "ANY"
  uri                         = "http://${local.api_gateway_target_url}:30567/api/v1/dataset/{datasetId}/widget/{widgetId}"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId"]
}

module "widget_any_dataset_id_widget_id_proxy" {
  source                      = "../../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_widget_id_proxy_resource.aws_api_gateway_resource
  method                      = "ANY"
  uri                         = "http://${local.api_gateway_target_url}:30567/api/v1/dataset/{datasetId}/widget/{widgetId}/{proxy}"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId", "widgetId"]
}
