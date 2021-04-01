resource "kubernetes_service" "gfw_prodes_service" {
  metadata {
    name      = "gfw-prodes"
    namespace = "gfw"
  }
  spec {
    selector = {
      name = "gfw-prodes"
    }
    port {
      port        = 30537
      node_port   = 30537
      target_port = 3600
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "gfw_prodes_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30537
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gfw_prodes_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "gfw_prodes_lb_target_group" {
  name        = "gfw-prodes-lb-tg"
  port        = 30537
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_gfw_prodes" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.gfw_prodes_lb_target_group.arn
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

// /v1/prodes-loss
resource "aws_api_gateway_resource" "v1_prodes_loss_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "prodes-loss"
}

// /v1/prodes-loss/{proxy+}
resource "aws_api_gateway_resource" "v1_prodes_loss_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_prodes_loss_resource.id
  path_part   = "{proxy+}"
}

// /v2/prodes-loss
resource "aws_api_gateway_resource" "v2_prodes_loss_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v2_resource.id
  path_part   = "prodes-loss"
}

// /v2/prodes-loss/{proxy+}
resource "aws_api_gateway_resource" "v2_prodes_loss_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_prodes_loss_resource.id
  path_part   = "{proxy+}"
}

module "gfw_prodes_loss_any_v2_prodes_loss_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_prodes_loss_proxy_resource
  method       = "ANY"
  uri          = "http://api.resourcewatch.org:30537/api/v2/prodes-loss/{proxy}"
  vpc_link     = var.vpc_link
}

module "gfw_prodes_loss_any_v1_prodes_loss_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_prodes_loss_proxy_resource
  method       = "ANY"
  uri          = "http://api.resourcewatch.org:30537/api/v1/prodes-loss/{proxy}"
  vpc_link     = var.vpc_link
}
