resource "kubernetes_service" "gfw_umd_service" {
  metadata {
    name      = "gfw-umd"
    namespace = "gfw"
  }
  spec {
    selector = {
      name = "gfw-umd"
    }
    port {
      port        = 30539
      node_port   = 30539
      target_port = 3600
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "gfw_umd_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30539
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gfw_umd_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "gfw_umd_lb_target_group" {
  name        = "gfw-umd-lb-tg"
  port        = 30539
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_gfw_umd" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.gfw_umd_lb_target_group.arn
}

// /v1/umd-loss-gain/admin
module "v1_umd_loss_gain_admin_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_umd_loss_gain_resource.id
  path_part   = "umd-loss-gain"
}

// /v1/umd-loss-gain/admin/{proxy+}
module "v1_umd_loss_gain_admin_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_umd_loss_gain_admin_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v2/umd-loss-gain
module "v2_umd_loss_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v2_resource.id
  path_part   = "umd-loss-gain"
}

// /v2/umd-loss-gain/{proxy+}
module "v2_umd_loss_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v2_umd_loss_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v3/umd-loss-gain
module "v3_umd_loss_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v3_resource.id
  path_part   = "umd-loss-gain"
}

// /v3/umd-loss-gain/{proxy+}
module "v3_umd_loss_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v3_umd_loss_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "gfw_umd_loss_any_v1_umd_loss_gain_admin_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = module.v1_umd_loss_gain_admin_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30539/api/v1/umd-loss-gain/admin/{proxy}"
  vpc_link     = var.vpc_link
}

module "gfw_umd_loss_any_v2_umd_loss_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = module.v2_umd_loss_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30539/api/v2/umd-loss-gain/{proxy}"
  vpc_link     = var.vpc_link
}

module "gfw_umd_loss_any_v3_umd_loss_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = module.v3_umd_loss_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30539/api/v3/umd-loss-gain/{proxy}"
  vpc_link     = var.vpc_link
}
