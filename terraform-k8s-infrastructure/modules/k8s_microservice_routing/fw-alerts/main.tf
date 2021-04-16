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

resource "aws_lb_listener" "fw_alerts_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
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
resource "aws_api_gateway_resource" "v1_fw_alerts_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "fw-alerts"
}

// /v1/fw-alerts/{proxy+}
resource "aws_api_gateway_resource" "v1_fw_alerts_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_fw_alerts_resource.id
  path_part   = "{proxy+}"
}

module "fw_alerts_any_v1_form_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_fw_alerts_proxy_resource
  method       = "ANY"
  uri          = "http://${var.load_balancer.dns_name}:30527/api/v1/fw-alerts/{proxy}"
  vpc_link     = var.vpc_link
}
