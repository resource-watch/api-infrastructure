resource "kubernetes_service" "subscriptions_service" {
  metadata {
    name      = "subscriptions"
    namespace = "gfw"
  }
  spec {
    selector = {
      name = "subscriptions"
    }
    port {
      port        = 30561
      node_port   = 30561
      target_port = 3600
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "subscriptions_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30561
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.subscriptions_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "subscriptions_lb_target_group" {
  name        = "subscriptions-lb-tg"
  port        = 30561
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_subscriptions" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.subscriptions_lb_target_group.arn
}

// /v1/subscriptions
module "v1_subscriptions_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "subscriptions"
}

// /v1/subscriptions/{proxy+}
module "v1_subscriptions_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_subscriptions_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "subscriptions_get_v1_subscriptions" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_subscriptions_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30561/api/v1/subscriptions"
  vpc_link     = var.vpc_link
}

module "subscriptions_post_v1_subscriptions" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_subscriptions_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30561/api/v1/subscriptions"
  vpc_link     = var.vpc_link
}

module "subscriptions_any_v1_subscriptions_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_subscriptions_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30561/api/v1/subscriptions/{proxy}"
  vpc_link     = var.vpc_link
}
