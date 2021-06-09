resource "kubernetes_service" "imazon_service" {
  metadata {
    name      = "imazon"
    namespace = "gfw"
  }
  spec {
    selector = {
      name = "imazon"
    }
    port {
      port        = 30545
      node_port   = 30545
      target_port = 3600
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "imazon_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30545
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.imazon_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "imazon_lb_target_group" {
  name        = "imazon-lb-tg"
  port        = 30545
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_imazon" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.imazon_lb_target_group.arn
}


// /v1/imazon-alerts
module "v1_imazon_alerts_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "imazon-alerts"
}

// /v1/imazon-alerts/{proxy+}
module "v1_imazon_alerts_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_imazon_alerts_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v2/imazon-alerts
module "v2_imazon_alerts_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v2_resource.id
  path_part   = "imazon-alerts"
}

// /v2/imazon-alerts/{proxy+}
module "v2_imazon_alerts_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v2_imazon_alerts_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "imazon_get_v1_imazon_alerts" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_imazon_alerts_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30545/api/v1/imazon-alerts"
  vpc_link     = var.vpc_link
}

module "imazon_post_v1_imazon_alerts" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_imazon_alerts_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30545/api/v1/imazon-alerts"
  vpc_link     = var.vpc_link
}

module "imazon_any_v1_imazon_alerts_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_imazon_alerts_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30545/api/v1/imazon-alerts/{proxy}"
  vpc_link     = var.vpc_link
}

module "imazon_get_v2_imazon_alerts" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v2_imazon_alerts_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30545/api/v2/imazon-alerts"
  vpc_link     = var.vpc_link
}

module "imazon_post_v2_imazon_alerts" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v2_imazon_alerts_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30545/api/v2/imazon-alerts"
  vpc_link     = var.vpc_link
}

module "imazon_any_v2_imazon_alerts_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v2_imazon_alerts_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30545/api/v2/imazon-alerts/{proxy}"
  vpc_link     = var.vpc_link
}