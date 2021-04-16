resource "kubernetes_service" "true_color_tiles_service" {
  metadata {
    name      = "true-color-tiles"
    namespace = "gfw"
  }
  spec {
    selector = {
      name = "true-color-tiles"
    }
    port {
      port        = 30563
      node_port   = 30563
      target_port = 3547
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "true_color_tiles_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30563
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.true_color_tiles_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "true_color_tiles_lb_target_group" {
  name        = "true-color-tiles-lb-tg"
  port        = 30563
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_true_color_tiles" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.true_color_tiles_lb_target_group.arn
}

// /v1/true-color-tiles
resource "aws_api_gateway_resource" "v1_true_color_tiles_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "true-color-tiles"
}

// /v1/true-color-tiles/{proxy+}
resource "aws_api_gateway_resource" "v1_true_color_tiles_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_true_color_tiles_resource.id
  path_part   = "{proxy+}"
}

module "true_color_tiles_get_v1_true_color_tiles_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_true_color_tiles_proxy_resource
  method       = "GET"
  uri          = "http://${var.load_balancer.dns_name}:30563/api/v1/true-color-tiles/{proxy}"
  vpc_link     = var.vpc_link
}

