resource "kubernetes_service" "control_tower_service" {
  metadata {
    name      = "control-tower"
    namespace = "gateway"

  }
  spec {
    selector = {
      name = "control-tower"
    }
    port {
      port        = 30513
      node_port   = 30513
      target_port = 9000
    }

    type = "NodePort"
  }
}


resource "aws_lb_listener" "control_tower_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30513
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.control_tower_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "control_tower_lb_target_group" {
  name        = "control-tower-lb-tg"
  port        = 30513
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_control_tower" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.control_tower_lb_target_group.arn
}

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v2
data "aws_api_gateway_resource" "v2_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v2"
}

// /v3
data "aws_api_gateway_resource" "v3_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v3"
}

// /v1/{proxy+}
resource "aws_api_gateway_resource" "control_tower_v1_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "{proxy+}"
}

// /v2/{proxy+}
resource "aws_api_gateway_resource" "control_tower_v2_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v2_resource.id
  path_part   = "{proxy+}"
}

// /v3/{proxy+}
resource "aws_api_gateway_resource" "control_tower_v3_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v3_resource.id
  path_part   = "{proxy+}"
}

module "control_tower_v1_any" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.control_tower_v1_proxy_resource
  method       = "ANY"
  uri          = "http://api.resourcewatch.org:30513/v1/{proxy}"
  vpc_link     = var.vpc_link
}

module "control_tower_v2_any" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.control_tower_v2_proxy_resource
  method       = "ANY"
  uri          = "http://api.resourcewatch.org:30523/v2/{proxy}"
  vpc_link     = var.vpc_link
}

module "control_tower_v3_any" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.control_tower_v3_proxy_resource
  method       = "ANY"
  uri          = "http://api.resourcewatch.org:30533/v3/{proxy}"
  vpc_link     = var.vpc_link
}
