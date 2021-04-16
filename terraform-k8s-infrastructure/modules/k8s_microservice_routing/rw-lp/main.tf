resource "kubernetes_service" "rw_lp_service" {
  metadata {
    name      = "rw-lp"
    namespace = "default"

  }
  spec {
    selector = {
      name = "rw-lp"
    }
    port {
      port        = 30559
      node_port   = 30559
      target_port = 8080
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "rw_lp_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30559
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rw_lp_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "rw_lp_lb_target_group" {
  name        = "rw-lp-lb-tg"
  port        = 30559
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_rw_lp" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.rw_lp_lb_target_group.arn
}

// /
data "aws_api_gateway_resource" "root_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/"
}

// /rw-lp
resource "aws_api_gateway_resource" "rw_lp_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.root_resource.id
  path_part   = "rw-lp"
}

// /rw-lp/{proxy+}
resource "aws_api_gateway_resource" "rw_lp_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.rw_lp_resource.id
  path_part   = "{proxy+}"
}

module "rw_lp_get_home" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = data.aws_api_gateway_resource.root_resource
  method       = "GET"
  uri          = "http://${var.load_balancer.dns_name}:30559/"
  vpc_link     = var.vpc_link
}

module "rw_lp_get_rw_lp_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.rw_lp_proxy_resource
  method       = "GET"
  uri          = "http://${var.load_balancer.dns_name}:30559/rw-lp/{proxy}"
  vpc_link     = var.vpc_link
}

