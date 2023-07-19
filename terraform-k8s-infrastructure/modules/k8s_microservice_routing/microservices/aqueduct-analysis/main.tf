resource "kubernetes_service" "aqueduct_analysis_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  metadata {
    name      = "aqueduct-analysis"
    namespace = "aqueduct"
  }
  spec {
    selector = {
      name = "aqueduct-analysis"
    }
    port {
      port        = 30501
      node_port   = 30501
      target_port = 5700
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

resource "aws_lb_listener" "aqueduct_analysis_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30501
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aqueduct_analysis_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "aqueduct_analysis_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  name        = "aqueduct-analysis-lb-tg"
  port        = 30501
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_aqueduct_analysis" {
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  lb_target_group_arn    = aws_lb_target_group.aqueduct_analysis_lb_target_group[0].arn
}

// /v1/aqueduct
module "v1_aqueduct_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "aqueduct"
}

// /v1/aqueduct/{proxy+}
module "v1_aqueduct_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_aqueduct_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "aqueduct_analysis_any_v1_aqueduct_proxy" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_aqueduct_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30501/api/v1/aqueduct/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = var.require_api_key
}
