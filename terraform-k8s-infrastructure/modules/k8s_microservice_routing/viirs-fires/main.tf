resource "kubernetes_service" "viirs_active_fires_service" {
  metadata {
    name      = "viirs-fires"
    namespace = "gfw"

  }
  spec {
    selector = {
      name = "viirs-fires"
    }
    port {
      port        = 30564
      node_port   = 30564
      target_port = 3600
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "viirs_active_fires_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30564
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.viirs_active_fires_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "viirs_active_fires_lb_target_group" {
  name        = "viirs-fires-lb-tg"
  port        = 30564
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_viirs_active_fires" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.viirs_active_fires_lb_target_group.arn
}


// /v1/viirs-active-fires
module "v1_viirs_active_fires_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "viirs-active-fires"
}

// /v1/viirs-active-fires/{proxy+}
module "v1_viirs_active_fires_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_viirs_active_fires_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v2/viirs-active-fires
module "v2_viirs_active_fires_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v2_resource.id
  path_part   = "viirs-active-fires"
}

// /v2/viirs-active-fires/{proxy+}
module "v2_viirs_active_fires_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v2_viirs_active_fires_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "viirs_fires_get_v1_viirs_active_fires" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_viirs_active_fires_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30564/api/v1/viirs-active-fires"
  vpc_link     = var.vpc_link
}

module "viirs_fires_post_v1_viirs_active_fires" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_viirs_active_fires_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30564/api/v1/viirs-active-fires"
  vpc_link     = var.vpc_link
}

module "viirs_fires_any_v1_viirs_active_fires_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_viirs_active_fires_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30564/api/v1/viirs-active-fires/{proxy}"
  vpc_link     = var.vpc_link
}

module "viirs_fires_get_v2_viirs_active_fires" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v2_viirs_active_fires_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30564/api/v2/viirs-active-fires"
  vpc_link     = var.vpc_link
}

module "viirs_fires_post_v2_viirs_active_fires" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v2_viirs_active_fires_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30564/api/v2/viirs-active-fires"
  vpc_link     = var.vpc_link
}

module "viirs_fires_any_v2_viirs_active_fires_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v2_viirs_active_fires_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30564/api/v2/viirs-active-fires/{proxy}"
  vpc_link     = var.vpc_link
}
