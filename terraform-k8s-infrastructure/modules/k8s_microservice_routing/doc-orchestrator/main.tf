resource "kubernetes_service" "doc_orchestrator_service" {
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

resource "aws_lb_listener" "doc_orchestrator_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30518
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.doc_orchestrator_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "doc_orchestrator_lb_target_group" {
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
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.doc_orchestrator_lb_target_group.arn
}

// /v1/doc-importer
resource "aws_api_gateway_resource" "doc_importer_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "doc-importer"
}

// /v1/doc-importer/{proxy+}
resource "aws_api_gateway_resource" "doc_importer_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.doc_importer_resource.id
  path_part   = "task"
}

module "doc_orchestrator_any_doc_importer_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.doc_importer_proxy_resource
  method       = "ANY"
  uri          = "http://${var.load_balancer.dns_name}:30518/api/v1/doc-importer/{proxy}"
  vpc_link     = var.vpc_link
}