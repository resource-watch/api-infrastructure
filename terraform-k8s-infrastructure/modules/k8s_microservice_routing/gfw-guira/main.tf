resource "kubernetes_service" "gfw_guira_service" {
  metadata {
    name      = "gfw-guira"
    namespace = "gfw"
  }
  spec {
    selector = {
      name = "gfw-guira"
    }
    port {
      port        = 30535
      node_port   = 30535
      target_port = 3600
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  arn  = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "gfw_guira_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30535
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gfw_guira_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "gfw_guira_lb_target_group" {
  name        = "gfw-guira-lb-tg"
  port        = 30535
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_gfw_guira" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.gfw_guira_lb_target_group.arn
}


// /v1/guira-loss
module "v1_guira_loss_resource" {
  source       = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "guira-loss"
}

// /v1/guira-loss/{proxy+}
module "v1_guira_loss_proxy_resource" {
  source       = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_guira_loss_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v2/guira-loss
module "v2_guira_loss_resource" {
  source       = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v2_resource.id
  path_part   = "guira-loss"
}

// /v2/guira-loss/{proxy+}
module "v2_guira_loss_proxy_resource" {
  source       = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v2_guira_loss_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "gfw_guira_get_v2_guira_loss" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = module.v2_guira_loss_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30535/api/v2/guira-loss"
  vpc_link     = var.vpc_link
}

module "gfw_guira_post_v2_guira_loss" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = module.v2_guira_loss_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30535/api/v2/guira-loss"
  vpc_link     = var.vpc_link
}

module "gfw_guira_any_v2_guira_loss_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = module.v2_guira_loss_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30535/api/v2/guira-loss/{proxy}"
  vpc_link     = var.vpc_link
}

module "gfw_guira_get_v1_guira_loss" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = module.v1_guira_loss_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30535/api/v1/guira-loss"
  vpc_link     = var.vpc_link
}

module "gfw_guira_post_v1_guira_loss" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = module.v1_guira_loss_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30535/api/v1/guira-loss"
  vpc_link     = var.vpc_link
}

module "gfw_guira_any_v1_guira_loss_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = module.v1_guira_loss_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30535/api/v1/guira-loss/{proxy}"
  vpc_link     = var.vpc_link
}
