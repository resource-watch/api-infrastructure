resource "kubernetes_service" "gfw_forma_service" {
  metadata {
    name      = "gfw-forma"
    namespace = "gfw"
  }
  spec {
    selector = {
      name = "gfw-forma"
    }
    port {
      port        = 30534
      node_port   = 30534
      target_port = 3600
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  arn  = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "gfw_forma_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30534
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gfw_forma_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "gfw_forma_lb_target_group" {
  name        = "gfw-forma-lb-tg"
  port        = 30534
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_gfw_forma" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.gfw_forma_lb_target_group.arn
}

// /v1/forma-alerts
resource "aws_api_gateway_resource" "v1_forma_alerts_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "forma-alerts"
}

// /v1/forma-alerts/{proxy+}
resource "aws_api_gateway_resource" "v1_forma_alerts_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_forma_alerts_resource.id
  path_part   = "{proxy+}"
}

module "gfw_forma_get_v1_forma_alerts" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_forma_alerts_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30534/api/v1/forma-alerts"
  vpc_link     = var.vpc_link
}

module "gfw_forma_post_v1_forma_alerts" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_forma_alerts_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30534/api/v1/forma-alerts"
  vpc_link     = var.vpc_link
}

module "gfw_forma_any_v1_forma_alerts_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_forma_alerts_proxy_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30534/api/v1/forma-alerts/{proxy}"
  vpc_link     = var.vpc_link
}