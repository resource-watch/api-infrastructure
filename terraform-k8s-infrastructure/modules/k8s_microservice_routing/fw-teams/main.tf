resource "kubernetes_service" "fw_teams_service" {
  metadata {
    name      = "fw-teams"
    namespace = "fw"
  }
  spec {
    selector = {
      name = "fw-teams"
    }
    port {
      port        = 30529
      node_port   = 30529
      target_port = 3035
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "fw_teams_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30529
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fw_teams_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "fw_teams_lb_target_group" {
  name        = "fw-teams-lb-tg"
  port        = 30529
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_fw_teams" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.fw_teams_lb_target_group.arn
}

// /v1/teams
module "v1_teams_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "teams"
}

// /v1/teams/{proxy+}
module "v1_teams_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_teams_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "fw_teams_post_v1_teams" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_teams_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30529/api/v1/teams"
  vpc_link     = var.vpc_link
}

module "fw_teams_any_v1_teams_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_teams_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30529/api/v1/teams/{proxy}"
  vpc_link     = var.vpc_link
}
