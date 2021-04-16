resource "kubernetes_service" "doc_swagger_service" {
  metadata {
    name = "doc-swagger"

  }
  spec {
    selector = {
      name = "doc-swagger"
    }
    port {
      port        = 30519
      node_port   = 30519
      target_port = 3500
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "doc_swagger_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30519
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.doc_swagger_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "doc_swagger_lb_target_group" {
  name        = "doc-swagger-lb-tg"
  port        = 30519
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_doc_swagger" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.doc_swagger_lb_target_group.arn
}

// /documentation
resource "aws_api_gateway_resource" "documentation_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.root_resource_id
  path_part   = "documentation"
}

// /documentation/{proxy+}
resource "aws_api_gateway_resource" "documentation_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.documentation_resource.id
  path_part   = "{proxy+}"
}

module "doc_swagger_any" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.documentation_resource
  method       = "ANY"
  uri          = "http://${var.load_balancer.dns_name}:30519/documentation"
  vpc_link     = var.vpc_link
}

module "doc_swagger_proxy_any" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.documentation_proxy_resource
  method       = "ANY"
  uri          = "http://${var.load_balancer.dns_name}:30519/documentation/{proxy}"
  vpc_link     = var.vpc_link
}