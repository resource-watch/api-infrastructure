resource "kubernetes_service" "gee_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  metadata {
    name = "gee"

  }
  spec {
    selector = {
      name = "gee"
    }
    port {
      port        = 30530
      node_port   = 30530
      target_port = 5700
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

resource "aws_lb_listener" "gee_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30530
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gee_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "gee_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  name        = "gee-lb-tg"
  port        = 30530
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_gee" {
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  lb_target_group_arn    = aws_lb_target_group.gee_lb_target_group[0].arn
}

// /v1/query/gee
module "query_gee_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_query_resource.id
  path_part   = "gee"
}

// /v1/query/gee/{datasetId}
module "query_gee_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.query_gee_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/download/gee
module "download_gee_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_download_resource.id
  path_part   = "gee"
}

// /v1/download/gee/{datasetId}
module "download_gee_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.download_gee_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields/gee
module "fields_gee_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_fields_resource.id
  path_part   = "gee"
}

// /v1/fields/gee/{datasetId}
module "fields_gee_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.fields_gee_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/rest-datasets/gee
module "rest_datasets_gee_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_rest_datasets_resource.id
  path_part   = "gee"
}

// /v1/rest-datasets/gee/{datasetId}
module "rest_datasets_gee_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.rest_datasets_gee_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

module "gee_get_query_gee_dataset_id" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.query_gee_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30530/api/v1/earthengine/query/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "gee_post_query_gee_dataset_id" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.query_gee_dataset_id_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30530/api/v1/earthengine/query/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "gee_get_download_gee_dataset_id" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.download_gee_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30530/api/v1/earthengine/download/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "gee_post_download_gee_dataset_id" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.download_gee_dataset_id_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30530/api/v1/earthengine/download/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "gee_get_fields_gee_dataset_id" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.fields_gee_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30530/api/v1/earthengine/fields/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "gee_get_rest_datasets_gee" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.rest_datasets_gee_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30530/api/v1/earthengine/rest-datasets/gee"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "gee_delete_rest_datasets_gee_dataset_id" {
  source          = "../../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.rest_datasets_gee_dataset_id_resource.aws_api_gateway_resource
  method          = "DELETE"
  uri             = "http://${local.api_gateway_target_url}:30530/api/v1/earthengine/rest-datasets/gee/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}
