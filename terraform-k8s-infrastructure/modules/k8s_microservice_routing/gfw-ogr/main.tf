resource "kubernetes_service" "gfw_ogr_service" {
  metadata {
    name      = "gfw-ogr"
    namespace = "gfw"
  }
  spec {
    selector = {
      name = "gfw-ogr"
    }
    port {
      port        = 30536
      node_port   = 30536
      target_port = 3200
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "gfw_ogr_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30536
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gfw_ogr_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "gfw_ogr_lb_target_group" {
  name        = "gfw-ogr-lb-tg"
  port        = 30536
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_gfw_ogr" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.gfw_ogr_lb_target_group.arn
}


// /v1/ogr
resource "aws_api_gateway_resource" "v1_ogr_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "ogr"
}

// /v1/ogr/{proxy+}
resource "aws_api_gateway_resource" "v1_ogr_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_ogr_resource.id
  path_part   = "{proxy+}"
}

// /v2/ogr
resource "aws_api_gateway_resource" "v2_ogr_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v2_resource.id
  path_part   = "ogr"
}

// /v2/ogr/{proxy+}
resource "aws_api_gateway_resource" "v2_ogr_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_ogr_resource.id
  path_part   = "{proxy+}"
}

module "gfw_ogr_any_v2_ogr_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_ogr_proxy_resource
  method       = "ANY"
  uri          = "http://${var.load_balancer.dns_name}:30536/api/v2/ogr/{proxy}"
  vpc_link     = var.vpc_link
}

module "gfw_ogr_any_v1_ogr_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_ogr_proxy_resource
  method       = "ANY"
  uri          = "http://${var.load_balancer.dns_name}:30536/api/v1/ogr/{proxy}"
  vpc_link     = var.vpc_link
}
