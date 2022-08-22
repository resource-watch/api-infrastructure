resource "kubernetes_service" "doc_orchestrator_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  metadata {
    name = "doc-orchestrator"

  }
  spec {
    selector = {
      name = "doc-orchestrator"
    }
    port {
      port        = 30518
      node_port   = 30518
      target_port = 5000
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

resource "aws_lb_listener" "doc_orchestrator_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30518
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.doc_orchestrator_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "doc_orchestrator_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  name        = "doc-orchestrator-lb-tg"
  port        = 30518
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_doc_orchestrator" {
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  lb_target_group_arn    = aws_lb_target_group.doc_orchestrator_lb_target_group[0].arn
}

// /v1/doc-importer
module "doc_importer_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "doc-importer"
}

// /v1/doc-importer/{proxy+}
module "doc_importer_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.doc_importer_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "doc_orchestrator_any_doc_importer_proxy" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.doc_importer_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30518/api/v1/doc-importer/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}
