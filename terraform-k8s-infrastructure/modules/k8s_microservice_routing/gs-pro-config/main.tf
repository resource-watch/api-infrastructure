resource "kubernetes_service" "gs_pro_config_service" {
  metadata {
    name      = "gs-pro-config"
    namespace = "gfw"
  }
  spec {
    selector = {
      name = "gs-pro-config"
    }
    port {
      port        = 30543
      node_port   = 30543
      target_port = 6700
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "gs_pro_config_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30543
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gs_pro_config_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "gs_pro_config_lb_target_group" {
  name        = "gs-pro-config-lb-tg"
  port        = 30543
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_gs_pro_config" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.gs_pro_config_lb_target_group.arn
}

// /v1/pro-config
resource "aws_api_gateway_resource" "v1_pro_config_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "pro-config"
}

// /v1/pro-config/{techTitle}
resource "aws_api_gateway_resource" "v1_pro_config_tech_title_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_pro_config_resource.id
  path_part   = "{techTitle}"
}

module "gs_pro_config_get_v1_pro_config_tech_title" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_pro_config_tech_title_resource
  method       = "GET"
  uri          = "http://${var.load_balancer.dns_name}:30543/api/v1/proconfig/{techTitle}"
  vpc_link     = var.vpc_link
}

