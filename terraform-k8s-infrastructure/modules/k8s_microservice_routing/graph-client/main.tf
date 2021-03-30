resource "kubernetes_service" "graph_client_service" {
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

resource "aws_lb_listener" "graph_client_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30542
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.graph_client_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "graph_client_lb_target_group" {
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
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.graph_client_lb_target_group.arn
}

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v1/graph
resource "aws_api_gateway_resource" "graph_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "graph"
}

// /v1/graph/query
resource "aws_api_gateway_resource" "graph_query_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_resource.id
  path_part   = "query"
}

// /v1/graph/{proxy+}
resource "aws_api_gateway_resource" "graph_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.graph_resource.id
  path_part   = "{proxy+}"
}

module "graph_client_any_graph_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.graph_query_resource
  method       = "ANY"
  uri          = "http://api.resourcewatch.org:30542/api/v1/graph/{proxy}"
  vpc_link     = var.vpc_link
}