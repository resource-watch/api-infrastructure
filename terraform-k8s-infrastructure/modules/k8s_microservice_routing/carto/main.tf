resource "kubernetes_service" "carto_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  metadata {
    name = "carto"

  }
  spec {
    selector = {
      name = "carto"
    }
    port {
      port        = 30507
      node_port   = 30507
      target_port = 3005
    }

    type = "NodePort"
  }
}

locals {
  api_gateway_target_url = var.connection_type == "VPC_LINK" ? data.aws_lb.load_balancer[0].dns_name : var.target_url
}

data "aws_lb" "load_balancer" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "carto_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30507
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.carto_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "carto_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  name        = "carto-lb-tg"
  port        = 30507
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_cartodb" {
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  lb_target_group_arn    = aws_lb_target_group.carto_lb_target_group[0].arn
}

// /v1/query/cartodb
module "v1_query_cartodb_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_query_resource.id
  path_part   = "cartodb"
}

// /v1/query/cartodb/{datasetId}
module "v1_query_cartodb_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_query_cartodb_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/download/cartodb
module "v1_download_cartodb_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_download_resource.id
  path_part   = "cartodb"
}

// /v1/download/cartodb/{datasetId}
module "v1_download_cartodb_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_download_cartodb_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields/cartodb
module "v1_fields_cartodb_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_fields_resource.id
  path_part   = "cartodb"
}

// /v1/fields/cartodb/{datasetId}
module "v1_fields_cartodb_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_fields_cartodb_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/rest-datasets/cartodb
module "v1_rest_datasets_cartodb_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_rest_datasets_resource.id
  path_part   = "cartodb"
}

// /v1/rest-datasets/cartodb/{datasetId}
module "v1_rest_datasets_cartodb_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_rest_datasets_cartodb_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

module "carto_get_v1_query_cartodb_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_query_cartodb_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30507/api/v1/carto/query/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "carto_post_v1_query_cartodb_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_query_cartodb_dataset_id_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30507/api/v1/carto/query/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "carto_get_v1_download_cartodb_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_download_cartodb_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30507/api/v1/carto/download/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "carto_post_v1_download_cartodb_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_download_cartodb_dataset_id_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30507/api/v1/carto/download/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "carto_get_v1_fields_cartodb_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_fields_cartodb_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30507/api/v1/carto/fields/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "carto_post_v1_rest_datasets_cartodb" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_rest_datasets_cartodb_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30507/api/v1/carto/rest-datasets/cartodb"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "carto_delete_v1_rest_datasets_cartodb_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_rest_datasets_cartodb_dataset_id_resource.aws_api_gateway_resource
  method          = "DELETE"
  uri             = "http://${local.api_gateway_target_url}:30507/api/v1/carto/rest-datasets/cartodb/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

