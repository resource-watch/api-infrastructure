resource "kubernetes_service" "high_res_service" {
  metadata {
    name      = "high-res"
    namespace = "gfw"
  }
  spec {
    selector = {
      name = "high-res"
    }
    port {
      port        = 30544
      node_port   = 30544
      target_port = 3050
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "high_res_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30544
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.high_res_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "high_res_lb_target_group" {
  name        = "high-res-lb-tg"
  port        = 30544
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_high_res" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.high_res_lb_target_group.arn
}

// /v1/high-res
resource "aws_api_gateway_resource" "v1_high_res_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "high-res"
}

// /v1/high-res/{sensor}
resource "aws_api_gateway_resource" "v1_high_res_sensor_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_high_res_resource.id
  path_part   = "{sensor}"
}

module "high_res_get_v1_high_res_sensor" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_high_res_sensor_resource
  method       = "GET"
  uri          = "http://${var.load_balancer.dns_name}:30544/api/v1/high-res/{sensor}"
  vpc_link     = var.vpc_link
}

