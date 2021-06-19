resource "kubernetes_service" "fw_alerts_service" {
  metadata {
    name      = "fw-alerts"
    namespace = "fw"
  }
  spec {
    selector = {
      name = "fw-alerts"
    }
    port {
      port        = 30527
      node_port   = 30527
      target_port = 4200
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "fw_alerts_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30527
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fw_alerts_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "fw_alerts_lb_target_group" {
  name        = "fw-alerts-lb-tg"
  port        = 30527
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_fw_alerts" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.fw_alerts_lb_target_group.arn
}

// /v1/fw-alerts
module "v1_fw_alerts_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "fw-alerts"
}

// /v1/fw-alerts/{proxy+}
module "v1_fw_alerts_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_fw_alerts_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "fw_alerts_any_v1_form_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_fw_alerts_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30527/api/v1/fw-alerts/{proxy}"
  vpc_link     = var.vpc_link
}
