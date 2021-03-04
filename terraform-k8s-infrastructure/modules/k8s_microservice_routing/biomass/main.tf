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

resource "aws_lb_listener" "biomass_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
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

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v1/biomass-loss
resource "aws_api_gateway_resource" "biomass_loss_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "biomass-loss"
}

// /v1/biomass-loss/admin
resource "aws_api_gateway_resource" "biomass_loss_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.biomass_loss_resource.id
  path_part   = "admin"
}

// /v1/biomass-loss/admin/{iso}
resource "aws_api_gateway_resource" "biomass_loss_admin_iso_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.biomass_loss_admin_resource.id
  path_part   = "{iso}"
}

// /v1/biomass-loss/admin/{iso}/{id}
resource "aws_api_gateway_resource" "biomass_loss_admin_iso_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.biomass_loss_admin_iso_resource.id
  path_part   = "{id}"
}


# Modules
module "biomass_v1_get_biomass_loss_admin_iso" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.biomass_loss_admin_iso_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30533/api/v1/biomass-loss/admin/{iso}"
  vpc_link     = var.vpc_link
}

module "biomass_v1_get_biomass_loss_admin_iso_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.biomass_loss_admin_iso_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30533/api/v1/biomass-loss/admin/{iso}/{id}"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["iso"]
}
