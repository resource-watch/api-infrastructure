resource "kubernetes_service" "fw_contextual_layers_service" {
  metadata {
    name      = "fw-contextual-layers"
    namespace = "fw"
  }
  spec {
    selector = {
      name = "fw-contextual-layers"
    }
    port {
      port        = 30528
      node_port   = 30528
      target_port = 3025
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  arn  = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "fw_contextual_layers_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30528
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fw_contextual_layers_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "fw_contextual_layers_lb_target_group" {
  name        = "fw-contextual-layers-lb-tg"
  port        = 30528
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_fw_contextual_layers" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.fw_contextual_layers_lb_target_group.arn
}

// /v1/contextual-layer
resource "aws_api_gateway_resource" "v1_contextual_layer_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "contextual-layer"
}

// /v1/contextual-layer/{proxy+}
resource "aws_api_gateway_resource" "v1_contextual_layer_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_contextual_layer_resource.id
  path_part   = "{proxy+}"
}

module "fw_contextual_layers_get_v1_contextual_layer" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_contextual_layer_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30528/api/v1/contextual-layer"
  vpc_link     = var.vpc_link
}

module "fw_contextual_layers_post_v1_contextual_layer" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_contextual_layer_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30528/api/v1/contextual-layer"
  vpc_link     = var.vpc_link
}

module "fw_contextual_layers_any_v1_contextual_layer_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_contextual_layer_proxy_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30528/api/v1/contextual-layer/{proxy}"
  vpc_link     = var.vpc_link
}
