resource "kubernetes_service" "proxy_service" {
  metadata {
    name      = "proxy"
    namespace = "prep"

  }
  spec {
    selector = {
      name = "proxy"
    }
    port {
      port        = 30554
      node_port   = 30554
      target_port = 5000
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "proxy_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30554
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.proxy_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "proxy_lb_target_group" {
  name        = "proxy-lb-tg"
  port        = 30554
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_proxy" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.proxy_lb_target_group.arn
}

// /v1
data "aws_api_gateway_resource" "proxy_v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v1/proxy
resource "aws_api_gateway_resource" "proxy_v1_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.proxy_v1_resource.id
  path_part   = "proxy"
}

// /v1/proxy/{proxy+}
resource "aws_api_gateway_resource" "proxy_v1_proxy_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.proxy_v1_proxy_resource.id
  path_part   = "{proxy+}"
}

module "gee_tiles_any_proxy_v1_proxy_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.proxy_v1_proxy_proxy_resource
  method       = "ANY"
  uri          = "http://api.resourcewatch.org:30554/api/v1/proxy/{proxy}"
  vpc_link     = var.vpc_link
}
