resource "kubernetes_service" "forms_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

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

locals {
  api_gateway_target_url = var.connection_type == "VPC_LINK" ? data.aws_lb.load_balancer[0].dns_name : var.target_url
}

data "aws_lb" "load_balancer" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "forms_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30526
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.forms_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "forms_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

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
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.forms_lb_target_group[0].arn
}

// /v1/questionnaire
module "v1_questionnaire_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "questionnaire"
}

// /v1/questionnaire/{proxy+}
module "v1_questionnaire_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_questionnaire_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/reports
module "v1_reports_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "reports"
}

// /v1/reports/{proxy+}
module "v1_reports_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_reports_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

#module "forms_any_v1_questionnaire" {
#  source          = "../endpoint"
#  x_rw_domain     = var.x_rw_domain
#  api_gateway     = var.api_gateway
#  api_resource    = module.v1_questionnaire_resource.aws_api_gateway_resource
#  method          = "ANY"
#  uri             = "http://${local.api_gateway_target_url}:30526/api/v1/questionnaire"
#  vpc_link        = var.vpc_link
#  connection_type = var.connection_type
#}

module "forms_any_v1_questionnaire" {
  source       = "../endpoint-proxy"
  api_gateway  = var.api_gateway
  backend_url  = "${var.backend_url}/api/v1/questionnaire"
  method       = "ANY"
  api_resource = module.v1_questionnaire_resource.aws_api_gateway_resource
}

#module "forms_any_v1_questionnaire_proxy" {
#  source          = "../endpoint"
#  x_rw_domain     = var.x_rw_domain
#  api_gateway     = var.api_gateway
#  api_resource    = module.v1_questionnaire_proxy_resource.aws_api_gateway_resource
#  method          = "ANY"
#  uri             = "http://${local.api_gateway_target_url}:30526/api/v1/questionnaire/{proxy}"
#  vpc_link        = var.vpc_link
#  connection_type = var.connection_type
#}

module "forms_any_v1_questionnaire_proxy" {
  source       = "../endpoint-proxy"
  api_gateway  = var.api_gateway
  backend_url  = "${var.backend_url}/api/v1/questionnaire/{proxy}"
  method       = "ANY"
  api_resource = module.v1_questionnaire_proxy_resource.aws_api_gateway_resource
}

#module "forms_any_v1_reports" {
#  source          = "../endpoint"
#  x_rw_domain     = var.x_rw_domain
#  api_gateway     = var.api_gateway
#  api_resource    = module.v1_reports_resource.aws_api_gateway_resource
#  method          = "ANY"
#  uri             = "http://${local.api_gateway_target_url}:30526/api/v1/reports"
#  vpc_link        = var.vpc_link
#  connection_type = var.connection_type
#}

module "forms_any_v1_reports" {
  source       = "../endpoint-proxy"
  api_gateway  = var.api_gateway
  backend_url  = "${var.backend_url}/api/v1/reports"
  method       = "ANY"
  api_resource = module.v1_reports_resource.aws_api_gateway_resource
}

#module "forms_any_v1_reports_proxy" {
#  source          = "../endpoint"
#  x_rw_domain     = var.x_rw_domain
#  api_gateway     = var.api_gateway
#  api_resource    = module.v1_reports_proxy_resource.aws_api_gateway_resource
#  method          = "ANY"
#  uri             = "http://${local.api_gateway_target_url}:30526/api/v1/reports/{proxy}"
#  vpc_link        = var.vpc_link
#  connection_type = var.connection_type
#}

module "forms_any_v1_reports_proxy" {
  source       = "../endpoint-proxy"
  api_gateway  = var.api_gateway
  backend_url  = "${var.backend_url}/api/v1/reports/{proxy}"
  method       = "ANY"
  api_resource = module.v1_reports_proxy_resource.aws_api_gateway_resource
}