resource "kubernetes_service" "aqueduct_analysis_service" {
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

resource "aws_lb_listener" "aqueduct_analysis_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30501
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aqueduct_analysis_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "aqueduct_analysis_lb_target_group" {
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
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.aqueduct_analysis_lb_target_group.arn
}

// /v1/aqueduct
resource "aws_api_gateway_resource" "v1_aqueduct_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "aqueduct"
}

// /v1/aqueduct/{proxy+}
resource "aws_api_gateway_resource" "v1_aqueduct_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_aqueduct_resource.id
  path_part   = "{proxy+}"
}

module "aqueduct_analysis_any_v1_aqueduct_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_aqueduct_proxy_resource
  method       = "ANY"
  uri          = "http://${var.load_balancer.dns_name}:30501/api/v1/aqueduct/{proxy}"
  vpc_link     = var.vpc_link
}