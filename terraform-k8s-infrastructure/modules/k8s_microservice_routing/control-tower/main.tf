resource "kubernetes_service" "control_tower_service" {
  metadata {
    name      = "control-tower"
    namespace = "gateway"

  }
  spec {
    selector = {
      name = "control-tower"
    }
    port {
      port        = 31000
      node_port   = 31000
      target_port = 9000
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "control_tower_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 31000
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.control_tower_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "control_tower_lb_target_group" {
  name        = "control-tower-lb-tg"
  port        = 31000
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_control_tower" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.control_tower_lb_target_group.arn
}

// /api
module "control_tower_api_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.api_gateway.root_resource_id
  path_part   = "api"
}

// /api/{proxy+}
module "control_tower_api_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.control_tower_api_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/{proxy+}
module "control_tower_proxy_v1_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "{proxy+}"
}


// /v2/{proxy+}
module "control_tower_proxy_v2_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v2_resource.id
  path_part   = "{proxy+}"
}


// /v3/{proxy+}
module "control_tower_proxy_v3_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v3_resource.id
  path_part   = "{proxy+}"
}

module "control_tower_v1_any" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.control_tower_proxy_v1_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:31000/v1/{proxy}"
  vpc_link     = var.vpc_link
}

module "control_tower_v2_any" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.control_tower_proxy_v2_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:31000/v2/{proxy}"
  vpc_link     = var.vpc_link
}

module "control_tower_v3_any" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.control_tower_proxy_v3_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:31000/v3/{proxy}"
  vpc_link     = var.vpc_link
}

module "control_tower_api_any" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.control_tower_api_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:31000/api/{proxy}"
  vpc_link     = var.vpc_link
}

