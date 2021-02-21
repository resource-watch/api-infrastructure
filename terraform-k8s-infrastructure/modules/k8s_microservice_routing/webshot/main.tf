resource "kubernetes_service" "webshot_service" {
  metadata {
    name      = "webshot"
    namespace = "default"

  }
  spec {
    selector = {
      name = "webshot"
    }
    port {
      port        = 30566
      node_port   = 30566
      target_port = 5000
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "webshot_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30566
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webshot_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "webshot_lb_target_group" {
  name        = "webshot-lb-tg"
  port        = 30566
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_webshot" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.webshot_lb_target_group.arn
}

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v1/webshot
resource "aws_api_gateway_resource" "webshot_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "webshot"
}

// /v1/webshot/pdf
resource "aws_api_gateway_resource" "webshot_pdf_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.webshot_resource.id
  path_part   = "pdf"
}

// /v1/webshot/widget
resource "aws_api_gateway_resource" "webshot_widget_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.webshot_resource.id
  path_part   = "widget"
}

// /v1/webshot/{widgetId}
resource "aws_api_gateway_resource" "webshot_widget_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.webshot_widget_resource.id
  path_part   = "{widgetId}"
}

// /v1/webshot/{widgetId}/thumbnail
resource "aws_api_gateway_resource" "webshot_widget_id_thumbnail_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.webshot_widget_id_resource.id
  path_part   = "thumbnail"
}

module "webshot_pdf" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.webshot_pdf_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30566/api/v1/webshot"
  vpc_link     = var.vpc_link
}

module "webshot_widget_id_thumbnail" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.webshot_widget_id_thumbnail_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30566/api/v1/webshot/widget/{widgetId}/thumbnail"
  vpc_link     = var.vpc_link
}