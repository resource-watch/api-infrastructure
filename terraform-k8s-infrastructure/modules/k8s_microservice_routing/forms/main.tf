resource "kubernetes_service" "forms_service" {
  metadata {
    name      = "forms"
    namespace = "fw"
  }
  spec {
    selector = {
      name = "forms"
    }
    port {
      port        = 30526
      node_port   = 30526
      target_port = 4400
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "forms_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30526
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.forms_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "forms_lb_target_group" {
  name        = "forms-lb-tg"
  port        = 30526
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_forms" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.forms_lb_target_group.arn
}

// /v1/form
resource "aws_api_gateway_resource" "v1_form_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "form"
}

// /v1/form/{proxy+}
resource "aws_api_gateway_resource" "v1_form_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_form_resource.id
  path_part   = "{proxy+}"
}

// /v1/questionnaire
resource "aws_api_gateway_resource" "v1_questionnaire_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "questionnaire"
}

// /v1/questionnaire/{proxy+}
resource "aws_api_gateway_resource" "v1_questionnaire_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_questionnaire_resource.id
  path_part   = "{proxy+}"
}

// /v1/reports
resource "aws_api_gateway_resource" "v1_reports_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "reports"
}

// /v1/reports/{proxy+}
resource "aws_api_gateway_resource" "v1_reports_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_reports_resource.id
  path_part   = "{proxy+}"
}

module "forms_any_v1_form_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_form_proxy_resource
  method       = "ANY"
  uri          = "http://${var.load_balancer.dns_name}:30526/api/v1/form/{proxy}"
  vpc_link     = var.vpc_link
}

module "forms_any_v1_questionnaire_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_questionnaire_proxy_resource
  method       = "ANY"
  uri          = "http://${var.load_balancer.dns_name}:30526/api/v1/questionnaire/{proxy}"
  vpc_link     = var.vpc_link
}

module "forms_any_v1_reports_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_reports_proxy_resource
  method       = "ANY"
  uri          = "http://${var.load_balancer.dns_name}:30526/api/v1/reports/{proxy}"
  vpc_link     = var.vpc_link
}