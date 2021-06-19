resource "kubernetes_service" "dataset_service" {
  metadata {
    name      = "dataset"
    namespace = "default"
  }
  spec {
    selector = {
      name = "dataset"
    }
    port {
      port        = 30516
      node_port   = 30516
      target_port = 3000
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "dataset_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
  port              = 30516
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dataset_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "dataset_lb_target_group" {
  name        = "dataset-lb-tg"
  port        = 30516
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_dataset" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.dataset_lb_target_group.arn
}

// /v1/dataset
module "dataset_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "dataset"
}

// /v1/rest-datasets
module "rest_datasets_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "rest-datasets"
}

// /v1/dataset/{datasetId}
module "dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.dataset_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/dataset/find-by-ids
module "dataset_find_by_ids_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.dataset_resource.aws_api_gateway_resource.id
  path_part   = "find-by-ids"
}

// /v1/dataset/upload
module "dataset_upload_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.dataset_resource.aws_api_gateway_resource.id
  path_part   = "upload"
}

// /v1/dataset/{datasetId}/{proxy+}
module "dataset_id_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.dataset_id_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "dataset_get_dataset" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.dataset_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30516/api/v1/dataset"
  vpc_link     = var.vpc_link
}

module "dataset_get_dataset_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.dataset_id_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30516/api/v1/dataset/{datasetId}"
  vpc_link     = var.vpc_link
}

module "dataset_update_dataset_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.dataset_id_resource.aws_api_gateway_resource
  method       = "PATCH"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30516/api/v1/dataset/{datasetId}"
  vpc_link     = var.vpc_link
}

module "dataset_delete_dataset_id" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.dataset_id_resource.aws_api_gateway_resource
  method       = "DELETE"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30516/api/v1/dataset/{datasetId}"
  vpc_link     = var.vpc_link
}

module "dataset_post_dataset" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.dataset_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30516/api/v1/dataset"
  vpc_link     = var.vpc_link
}

module "dataset_any_dataset_id_proxy" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_proxy_resource.aws_api_gateway_resource
  method                      = "ANY"
  uri                         = "http://${data.aws_lb.load_balancer.dns_name}:30516/api/v1/dataset/{datasetId}/{proxy}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "dataset_post_dataset_find_by_ids" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.dataset_find_by_ids_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30516/api/v1/dataset/find-by-ids"
  vpc_link     = var.vpc_link
}

module "dataset_post_dataset_upload" {
  source       = "../endpoint"
  x_rw_domain  = var.x_rw_domain
  api_gateway  = var.api_gateway
  api_resource = module.dataset_upload_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30516/api/v1/dataset/upload"
  vpc_link     = var.vpc_link
}
