resource "kubernetes_service" "gfw_user_service" {
  metadata {
    name      = "gfw-user"
    namespace = "gfw"
  }
  spec {
    selector = {
      name = "gfw-user"
    }
    port {
      port        = 30540
      node_port   = 30540
      target_port = 3100
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "gfw_user_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30540
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gfw_user_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "gfw_user_lb_target_group" {
  name        = "gfw-user-lb-tg"
  port        = 30540
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_gfw_user" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.gfw_user_lb_target_group.arn
}

// /v1/user
module "v1_user_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "user"
}

// /v1/user/{proxy+}
module "v1_user_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_user_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "gfw_user_get_v1_user" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_user_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30540/api/v1/user"
  vpc_link     = var.vpc_link
}

module "gfw_user_post_v1_user" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_user_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30540/api/v1/user"
  vpc_link     = var.vpc_link
}

module "gfw_user_any_v1_user_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_user_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30540/api/v1/user/{proxy}"
  vpc_link     = var.vpc_link
}
