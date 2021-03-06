resource "kubernetes_service" "webshot_service" {
  metadata {
    name      = "webshot"
    namespace = "default"

  }
  spec {
    selector = {
      name = "webshot"
    }
    port {
      port        = 30566
      node_port   = 30566
      target_port = 5000
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "webshot_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30566
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webshot_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "webshot_lb_target_group" {
  name        = "webshot-lb-tg"
  port        = 30566
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_webshot" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.webshot_lb_target_group.arn
}

// /v1/webshot
module "webshot_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "webshot"
}

// /v1/webshot/{proxy+}
module "webshot_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.webshot_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "webshot_get_v1_webshot" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.webshot_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30566/api/v1/webshot"
  vpc_link     = var.vpc_link
}

module "webshot_any_v1_webshot_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.webshot_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30566/api/v1/webshot/{proxy}"
  vpc_link     = var.vpc_link
}