resource "kubernetes_service" "forest_change_service" {
  metadata {
    name      = "forest-change"
    namespace = "gfw"
  }
  spec {
    selector = {
      name = "forest-change"
    }
    port {
      port        = 30524
      node_port   = 30524
      target_port = 62000
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  arn  = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "forest_change_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30524
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.forest_change_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "forest_change_lb_target_group" {
  name        = "forest-change-lb-tg"
  port        = 30524
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_forest_change" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.forest_change_lb_target_group.arn
}

// /v1/terrai-alerts
resource "aws_api_gateway_resource" "v1_terrai_alerts_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "terrai-alerts"
}

// /v1/terrai-alerts/{proxy+}
resource "aws_api_gateway_resource" "v1_terrai_alerts_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_terrai_alerts_resource.id
  path_part   = "{proxy+}"
}

module "forest_change_get_v1_terrai_alerts" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_terrai_alerts_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30524/api/v2/ms/terrai-alerts"
  vpc_link     = var.vpc_link
}

module "forest_change_post_v1_terrai_alerts" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_terrai_alerts_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30524/api/v2/ms/terrai-alerts"
  vpc_link     = var.vpc_link
}

module "forest_change_any_v1_terrai_alerts_admin_iso_code" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_terrai_alerts_proxy_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30524/api/v2/ms/terrai-alerts/{proxy}"
  vpc_link     = var.vpc_link
}