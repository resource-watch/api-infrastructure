resource "kubernetes_service" "bigquery_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  metadata {
    name = "bigquery"

  }
  spec {
    selector = {
      name = "bigquery"
    }
    port {
      port        = 30506
      node_port   = 30506
      target_port = 3095
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

resource "aws_lb_listener" "bigquery_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30506
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bigquery_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "bigquery_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  name        = "bigquery-lb-tg"
  port        = 30506
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_bigquery" {
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  lb_target_group_arn   = aws_lb_target_group.bigquery_lb_target_group[0].arn
}

// /v1/query/bigquery
module "v1_query_bigquery_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_query_resource.id
  path_part   = "bigquery"
}

// /v1/query/bigquery/{datasetId}
module "v1_query_bigquery_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_query_bigquery_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/download/bigquery
module "v1_download_bigquery_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_download_resource.id
  path_part   = "bigquery"
}

// /v1/download/bigquery/{datasetId}
module "v1_download_bigquery_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_download_bigquery_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields/bigquery
module "v1_fields_bigquery_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_fields_resource.id
  path_part   = "bigquery"
}

// /v1/fields/bigquery/{datasetId}
module "v1_fields_bigquery_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_fields_bigquery_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/rest-datasets/bigquery
module "v1_rest_datasets_bigquery_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_rest_datasets_resource.id
  path_part   = "bigquery"
}

module "bigquery_get_v1_query_bigquery_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_query_bigquery_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30506/api/v1/bigquery/query/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "bigquery_post_v1_query_bigquery_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_query_bigquery_dataset_id_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30506/api/v1/bigquery/query/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "bigquery_get_v1_download_bigquery_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_download_bigquery_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30506/api/v1/bigquery/download/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "bigquery_post_v1_download_bigquery_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_download_bigquery_dataset_id_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30506/api/v1/bigquery/download/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "bigquery_get_v1_fields_bigquery_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_fields_bigquery_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30506/api/v1/bigquery/fields/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "bigquery_post_v1_rest_datasets_bigquery" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_rest_datasets_bigquery_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30506/api/v1/bigquery/rest-datasets/bigquery"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

