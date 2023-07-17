resource "kubernetes_service" "gfw_user_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

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

locals {
  api_gateway_target_url = var.connection_type == "VPC_LINK" ? data.aws_lb.load_balancer[0].dns_name : var.target_url
}

data "aws_lb" "load_balancer" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "gfw_user_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30540
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gfw_user_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "gfw_user_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

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
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  lb_target_group_arn    = aws_lb_target_group.gfw_user_lb_target_group[0].arn
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

// /v2/user
module "v2_user_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v2_resource.id
  path_part   = "user"
}

// /v2/user/{proxy+}
module "v2_user_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v2_user_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "gfw_user_get_v1_user" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_user_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30540/api/v1/user"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "gfw_user_post_v1_user" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_user_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30540/api/v1/user"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "gfw_user_any_v1_user_proxy" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_user_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30540/api/v1/user/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "gfw_user_get_v2_user" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v2_user_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30540/api/v2/user"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "gfw_user_post_v2_user" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v2_user_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30540/api/v2/user"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "gfw_user_any_v2_user_proxy" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v2_user_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30540/api/v2/user/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}
