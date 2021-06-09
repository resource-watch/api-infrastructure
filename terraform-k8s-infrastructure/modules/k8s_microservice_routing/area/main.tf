resource "kubernetes_service" "area_service" {
  metadata {
    name      = "area"
    namespace = "gfw"

  }
  spec {
    selector = {
      name = "area"
    }
    port {
      port        = 30504
      node_port   = 30504
      target_port = 4100
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "area_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30504
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.area_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "area_lb_target_group" {
  name        = "area-lb-tg"
  port        = 30504
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_area" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.area_lb_target_group.arn
}


// /v2/area
module "v2_area_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v2_resource.id
  path_part   = "area"
}

// /v2/area/{proxy+}
module "v2_area_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v2_area_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v2/download-tiles
module "v2_download_tiles_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v2_resource.id
  path_part   = "download-tiles"
}

// /v2/download-tiles/{proxy+}
module "v2_download_tiles_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v2_download_tiles_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/area
module "v1_area_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "area"
}

// /v1/area/{proxy+}
module "v1_area_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_area_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/download-tiles
module "v1_download_tiles_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "download-tiles"
}

// /v1/download-tiles/{proxy+}
module "v1_download_tiles_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_download_tiles_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "area_get_area_v2" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v2_area_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30504/api/v2/area"
  vpc_link     = var.vpc_link
}

module "area_post_area_v2" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v2_area_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30504/api/v2/area"
  vpc_link     = var.vpc_link
}

module "area_any_area_v2_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v2_area_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30504/api/v2/area/{proxy}"
  vpc_link     = var.vpc_link
}

module "area_get_v1_area" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_area_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30504/api/v1/area"
  vpc_link     = var.vpc_link
}

module "area_post_v1_area" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_area_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30504/api/v1/area"
  vpc_link     = var.vpc_link
}

module "area_any_v1_area_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_area_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30504/api/v1/area/{proxy}"
  vpc_link     = var.vpc_link
}

module "area_any_v1_download_tiles_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v1_download_tiles_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30504/api/v1/download-tiles/{proxy}"
  vpc_link     = var.vpc_link
}

module "area_any_v2_download_tiles_proxy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.v2_download_tiles_proxy_resource.aws_api_gateway_resource
  method       = "ANY"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30504/api/v2/download-tiles/{proxy}"
  vpc_link     = var.vpc_link
}