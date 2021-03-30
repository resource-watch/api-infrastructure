resource "kubernetes_service" "converter_service" {
  metadata {
    name = "converter"

  }
  spec {
    selector = {
      name = "converter"
    }
    port {
      port        = 30514
      node_port   = 30514
      target_port = 4100
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "convert_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30514
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.convert_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "convert_lb_target_group" {
  name        = "convert-lb-tg"
  port        = 30514
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_convert" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.convert_lb_target_group.arn
}

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v1/converter
resource "aws_api_gateway_resource" "converter_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "converter"
}

// /v1/converter/{proxy+}
resource "aws_api_gateway_resource" "converter_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.converter_resource.id
  path_part   = "{proxy+}"
}

module "converter_any_converter_fs2sql" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.converter_proxy_resource
  method       = "ANY"
  uri          = "http://api.resourcewatch.org:30514/api/v1/convert/{proxy}"
  vpc_link     = var.vpc_link
}
