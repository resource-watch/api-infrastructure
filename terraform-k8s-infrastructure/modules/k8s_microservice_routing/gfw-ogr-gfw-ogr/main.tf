resource "kubernetes_service" "gfw_ogr_gfw_pro_service" {
  metadata {
    name      = "gfw-ogr-gfw-pro"
    namespace = "default"
  }
  spec {
    selector = {
      name = "gfw-ogr-gfw-pro"
    }
    port {
      port        = 30568
      node_port   = 30568
      target_port = 3200
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "gfw_ogr_gfw_pro_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30568
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gfw_ogr_gfw_pro_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "gfw_ogr_gfw_pro_lb_target_group" {
  name        = "gfw-ogr-gfw-pro-lb-tg"
  port        = 30568
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_gfw_ogr_gfw_pro" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.gfw_ogr_gfw_pro_lb_target_group.arn
}

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v1/gfw-pro
resource "aws_api_gateway_resource" "v1_gfw_pro_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "gfw-pro"
}

// /v1/gfw-pro/{proxy+}
resource "aws_api_gateway_resource" "v1_gfw_pro_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_gfw_pro_resource.id
  path_part   = "{proxy+}"
}

module "gfw_ogr_any_v1_gfw_pro_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_gfw_pro_proxy_resource
  method       = "ANY"
  uri          = "http://api.resourcewatch.org:30568/api/v1/{proxy}"
  vpc_link     = var.vpc_link
}
