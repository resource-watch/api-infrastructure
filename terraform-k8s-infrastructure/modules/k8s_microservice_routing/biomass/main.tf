resource "kubernetes_service" "biomass_service" {
  metadata {
    name = "biomass"

  }
  spec {
    selector = {
      name = "biomass"
    }
    port {
      port        = 30533
      node_port   = 30533
      target_port = 3600
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "biomass_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30533
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.biomass_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "biomass_lb_target_group" {
  name        = "biomass-lb-tg"
  port        = 30533
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_biomass" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.biomass_lb_target_group.arn
}

// /v1/biomass-loss/admin
module "biomass_loss_admin_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_biomass_loss_resource.id
  path_part   = "admin"
}

// /v1/biomass-loss/admin/{proxy+}
module "biomass_loss_admin_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.biomass_loss_admin_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

# Modules
module "biomass_v1_any_biomass_loss_admin_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.biomass_loss_admin_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30533/api/v1/biomass-loss/admin/{proxy}"
  vpc_link     = var.vpc_link
}
