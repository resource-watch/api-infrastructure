resource "kubernetes_service" "fw_alerts_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

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

locals {
  api_gateway_target_url = var.connection_type == "VPC_LINK" ? data.aws_lb.load_balancer[0].dns_name : var.target_url
}

data "aws_lb" "load_balancer" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "fw_alerts_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30527
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fw_alerts_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "fw_alerts_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

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
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.fw_alerts_lb_target_group[0].arn
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
  source       = "../endpoint-proxy"
  api_gateway  = var.api_gateway
  backend_url  = "${var.backend_url}/v1/fw-alerts/{proxy}"
  method       = "ANY"
  api_resource = module.v1_fw_alerts_proxy_resource.aws_api_gateway_resource
}