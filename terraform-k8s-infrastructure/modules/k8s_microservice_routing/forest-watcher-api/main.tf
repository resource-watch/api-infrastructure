resource "kubernetes_service" "forest_watcher_api_service" {
  metadata {
    name      = "forest-watcher-api"
    namespace = "fw"
  }
  spec {
    selector = {
      name = "forest-watcher-api"
    }
    port {
      port        = 30525
      node_port   = 30525
      target_port = 3600
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "forest_watcher_api_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30525
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.forest_watcher_api_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "forest_watcher_api_lb_target_group" {
  name        = "forest-watcher-api-lb-tg"
  port        = 30525
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_forest_watcher_api" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.forest_watcher_api_lb_target_group.arn
}

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v1/forest-watcher
resource "aws_api_gateway_resource" "v1_forest_watcher_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "forest-watcher"
}

// /v1/forest-watcher/area
resource "aws_api_gateway_resource" "v1_forest_watcher_area_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_forest_watcher_area_resource.id
  path_part   = "area"
}

module "forest_watcher_api_get_v1_forest_watcher_area_resource" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_forest_watcher_area_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30525/api/v1/forest-watcher/area"
  vpc_link     = var.vpc_link
}

module "forest_watcher_api_post_v1_forest_watcher_area_resource" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_forest_watcher_area_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30525/api/v1/forest-watcher/area"
  vpc_link     = var.vpc_link
}
