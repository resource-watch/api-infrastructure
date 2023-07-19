locals {
  api_gateway_target_url = var.connection_type == "VPC_LINK" ? data.aws_lb.load_balancer[0].dns_name : var.target_url
  port                   = 30571
}

resource "kubernetes_service" "gfw_adapter_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  metadata {
    name = "gfw-adapter"

  }
  spec {
    selector = {
      name = "gfw-adapter"
    }
    port {
      port        = local.port
      node_port   = local.port
      target_port = 3025
    }

    type = "NodePort"
  }
}

data "aws_lb" "load_balancer" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "gfw_adapter_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = local.port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gfw_adapter_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "gfw_adapter_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  name        = "gfw-adapter-lb-tg"
  port        = local.port
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_gfw" {
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  lb_target_group_arn    = aws_lb_target_group.gfw_adapter_lb_target_group[0].arn
}

// /v1/query/gfw
module "v1_query_gfw_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_query_resource.id
  path_part   = "gfw"
}

// /v1/query/gfw/{datasetId}
module "v1_query_gfw_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_query_gfw_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/download/gfw
module "v1_download_gfw_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_download_resource.id
  path_part   = "gfw"
}

// /v1/download/gfw/{datasetId}
module "v1_download_gfw_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_download_gfw_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields/gfw
module "v1_fields_gfw_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_fields_resource.id
  path_part   = "gfw"
}

// /v1/fields/gfw/{datasetId}
module "v1_fields_gfw_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_fields_gfw_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/rest-datasets/gfw
module "v1_rest_datasets_gfw_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_rest_datasets_resource.id
  path_part   = "gfw"
}

// /v1/rest-datasets/gfw/{datasetId}
module "v1_rest_datasets_gfw_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_rest_datasets_gfw_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

module "gfw_get_v1_query_gfw_dataset_id" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_query_gfw_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:${local.port}/api/v1/gfw/query/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = var.require_api_key
}

module "gfw_post_v1_query_gfw_dataset_id" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_query_gfw_dataset_id_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:${local.port}/api/v1/gfw/query/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = var.require_api_key
}

module "gfw_get_v1_download_gfw_dataset_id" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_download_gfw_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:${local.port}/api/v1/gfw/download/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = var.require_api_key
}

module "gfw_post_v1_download_gfw_dataset_id" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_download_gfw_dataset_id_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:${local.port}/api/v1/gfw/download/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = var.require_api_key
}

module "gfw_get_v1_fields_gfw_dataset_id" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_fields_gfw_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:${local.port}/api/v1/gfw/fields/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = var.require_api_key
}

module "gfw_post_v1_rest_datasets_gfw" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_rest_datasets_gfw_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:${local.port}/api/v1/gfw/rest-datasets/gfw"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = var.require_api_key
}

module "gfw_delete_v1_rest_datasets_gfw_dataset_id" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_rest_datasets_gfw_dataset_id_resource.aws_api_gateway_resource
  method          = "DELETE"
  uri             = "http://${local.api_gateway_target_url}:${local.port}/api/v1/gfw/rest-datasets/gfw/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
  require_api_key = var.require_api_key
}

