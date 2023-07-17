resource "kubernetes_service" "graph_client_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  metadata {
    name      = "graph-client"
    namespace = "default"

  }
  spec {
    selector = {
      name = "graph-client"
    }
    port {
      port        = 30542
      node_port   = 30542
      target_port = 4500
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

resource "aws_lb_listener" "graph_client_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30542
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.graph_client_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "graph_client_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  name        = "graph-client-lb-tg"
  port        = 30542
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_graph_client" {
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  lb_target_group_arn    = aws_lb_target_group.graph_client_lb_target_group[0].arn
}

// /v1/graph
module "graph_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "graph"
}

// /v1/graph/{proxy+}
module "graph_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.graph_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "graph_client_any_graph_proxy" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.graph_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30542/api/v1/graph/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}
