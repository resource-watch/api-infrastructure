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

data "aws_lb" "load_balancer" {
  arn  = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "converter_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30514
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.converter_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "converter_lb_target_group" {
  name        = "converter-lb-tg"
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
  alb_target_group_arn   = aws_lb_target_group.converter_lb_target_group.arn
}

// /v1/convert
module "convert_resource" {
  source       = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "convert"
}

// /v1/convert/{proxy+}
module "convert_proxy_resource" {
  source       = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.convert_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "converter_any_convert_fs2sql" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = module.convert_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30514/api/v1/convert/{proxy}"
  vpc_link     = var.vpc_link
}
