resource "kubernetes_service" "story_service" {
  metadata {
    name      = "story"
    namespace = "gfw"
  }
  spec {
    selector = {
      name = "story"
    }
    port {
      port        = 30560
      node_port   = 30560
      target_port = 3500
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "story_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30560
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.story_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "story_lb_target_group" {
  name        = "story-lb-tg"
  port        = 30560
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_story" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.story_lb_target_group.arn
}

// /v1/story
module "v1_story_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "story"
}

// /v1/story/{proxy+}
module "v1_story_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_story_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "story_get_v1_story" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_story_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30560/api/v1/story"
  vpc_link     = var.vpc_link
}

module "story_post_v1_story" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_story_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30560/api/v1/story"
  vpc_link     = var.vpc_link
}

module "story_any_v1_story_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_story_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30560/api/v1/story/{proxy}"
  vpc_link     = var.vpc_link
}
