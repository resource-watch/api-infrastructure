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

data "aws_lb" "load_balancer" {
  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "high_res_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
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
module "v1_high_res_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "high-res"
}

// /v1/high-res/{sensor}
module "v1_high_res_sensor_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_high_res_resource.aws_api_gateway_resource.id
  path_part   = "{sensor}"
}

module "high_res_get_v1_high_res_sensor" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_high_res_sensor_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30544/api/v1/high-res/{sensor}"
  vpc_link     = var.vpc_link
}

