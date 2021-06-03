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

data "aws_lb" "load_balancer" {
  arn  = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "widget_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
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

// /v1/widget
module "widget_resource" {
  source       = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "widget"
}

// /v1/widget/{proxy+}
module "widget_proxy_resource" {
  source       = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.widget_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/dataset/{datasetId}/widget
module "dataset_id_widget_resource" {
  source       = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_dataset_id_resource.id
  path_part   = "widget"
}

// /v1/dataset/{datasetId}/widget/{widgetId}
module "dataset_id_widget_id_resource" {
  source       = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.dataset_id_widget_resource.aws_api_gateway_resource.id
  path_part   = "{widgetId}"
}

// /v1/dataset/{datasetId}/widget/{widgetId}/{proxy+}
module "dataset_id_widget_id_proxy_resource" {
  source       = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.dataset_id_widget_id_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "widget_get_widget" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = module.widget_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30567/api/v1/widget"
  vpc_link     = var.vpc_link
}

module "widget_post_widget" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = module.widget_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30567/api/v1/widget"
  vpc_link     = var.vpc_link
}

module "widget_any_widget_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = module.widget_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30567/api/v1/widget/{proxy}"
  vpc_link     = var.vpc_link
}

module "widget_any_dataset_id_widget" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_widget_resource.aws_api_gateway_resource
  method                      = "ANY"
  uri                         = "http://${data.aws_lb.load_balancer.dns_name}:30567/api/v1/dataset/{datasetId}/widget"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "widget_any_dataset_id_widget_id" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_widget_id_resource.aws_api_gateway_resource
  method                      = "ANY"
  uri                         = "http://${data.aws_lb.load_balancer.dns_name}:30567/api/v1/dataset/{datasetId}/widget/{widgetId}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "widget_any_dataset_id_widget_id_proxy" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_widget_id_proxy_resource.aws_api_gateway_resource
  method                      = "ANY"
  uri                         = "http://${data.aws_lb.load_balancer.dns_name}:30567/api/v1/dataset/{datasetId}/widget/{widgetId}/{proxy}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId", "widgetId"]
}