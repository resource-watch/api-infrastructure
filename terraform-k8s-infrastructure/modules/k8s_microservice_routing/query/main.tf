resource "kubernetes_service" "query_service" {
  metadata {
    name      = "query"
    namespace = "default"

  }
  spec {
    selector = {
      name = "query"
    }
    port {
      port        = 30555
      node_port   = 30555
      target_port = 5000
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "query_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30555
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.query_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "query_lb_target_group" {
  name        = "query-lb-tg"
  port        = 30555
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_query" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.query_lb_target_group.arn
}

// /v1/query
module "query_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "query"
}

// /v1/download
module "download_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "download"
}

// /v1/jiminy
module "jiminy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "jiminy"
}

// /v1/fields
module "fields_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "fields"
}

// /v1/query/{datasetId}
module "query_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.query_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/download/{datasetId}
module "download_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.download_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields/{datasetId}
module "fields_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.fields_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

module "query_get_query" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.query_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30555/api/v1/query"
  vpc_link     = var.vpc_link
}

module "query_post_query" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.query_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30555/api/v1/query"
  vpc_link     = var.vpc_link
}

module "query_get_query_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.query_dataset_id_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30555/api/v1/query/{datasetId}"
  vpc_link     = var.vpc_link
}

module "query_post_query_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.query_dataset_id_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30555/api/v1/query/{datasetId}"
  vpc_link     = var.vpc_link
}

module "download_get_download" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.download_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30555/api/v1/download"
  vpc_link     = var.vpc_link
}

module "download_post_download" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.download_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30555/api/v1/download"
  vpc_link     = var.vpc_link
}

module "download_get_download_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.download_dataset_id_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30555/api/v1/download/{datasetId}"
  vpc_link     = var.vpc_link
}

module "download_post_download_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.download_dataset_id_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30555/api/v1/download/{datasetId}"
  vpc_link     = var.vpc_link
}

module "jiminy_get_jiminy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.jiminy_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30555/api/v1/jiminy"
  vpc_link     = var.vpc_link
}

module "jiminy_post_jiminy" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.jiminy_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30555/api/v1/jiminy"
  vpc_link     = var.vpc_link
}

module "fields_get_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.fields_dataset_id_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30555/api/v1/fields/{datasetId}"
  vpc_link     = var.vpc_link
}
