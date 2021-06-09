resource "kubernetes_service" "authorization_service" {
  metadata {
    name      = "authorization"
    namespace = "core"

  }
  spec {
    selector = {
      name = "authorization"
    }
    port {
      port        = 30505
      node_port   = 30505
      target_port = 9000
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "authorization_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30505
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.authorization_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "authorization_lb_target_group" {
  name        = "authorization-lb-tg"
  port        = 30505
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_authorization" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.authorization_lb_target_group.arn
}

// /auth
module "authorization_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.root_resource_id
  path_part   = "auth"
}
// /auth/{proxy+}
module "authorization_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.authorization_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "authorization_any_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = module.authorization_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30505/auth/{proxy}"
  vpc_link     = var.vpc_link
}

module "authorization_get" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = module.authorization_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30505/auth"
  vpc_link     = var.vpc_link
}
