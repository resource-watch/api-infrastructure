resource "kubernetes_service" "arcgis_proxy_service" {
  metadata {
    name      = "arcgis-proxy"
    namespace = "gfw"
  }
  spec {
    selector = {
      name = "arcgis-proxy"
    }
    port {
      port        = 30503
      node_port   = 30503
      target_port = 5700
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "arcgis_proxy_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30503
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.arcgis_proxy_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "arcgis_proxy_lb_target_group" {
  name        = "arcgis-proxy-lb-tg"
  port        = 30503
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_arcgis_proxy" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.arcgis_proxy_lb_target_group.arn
}

// /v1/arcgis-proxy
module "v1_arcgis_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "arcgis-proxy"
}

// /v1/arcgis-proxy/{proxy+}
module "v1_arcgis_proxy_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_arcgis_proxy_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "arcgis_proxy_any_v1_arcgis_proxy_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_arcgis_proxy_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30503/api/v1/arcgis-proxy/{proxy}"
  vpc_link     = var.vpc_link
}