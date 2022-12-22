resource "kubernetes_service" "arcgis_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  metadata {
    name = "arcgis"

  }
  spec {
    selector = {
      name = "arcgis"
    }
    port {
      port        = 30502
      node_port   = 30502
      target_port = 3055
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

resource "aws_lb_listener" "arcgis_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30502
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.arcgis_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "arcgis_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  name        = "arcgis-lb-tg"
  port        = 30502
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_arcgis" {
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  lb_target_group_arn   = aws_lb_target_group.arcgis_lb_target_group[0].arn
}

// /v1/query/featureservice
module "v1_query_featureservice_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_query_resource.id
  path_part   = "featureservice"
}

// /v1/query/featureservice/{datasetId}
module "v1_query_featureservice_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_query_featureservice_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/download/featureservice
module "v1_download_featureservice_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_download_resource.id
  path_part   = "featureservice"
}

// /v1/download/featureservice/{datasetId}
module "v1_download_featureservice_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_download_featureservice_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields/featureservice
module "v1_fields_featureservice_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_fields_resource.id
  path_part   = "featureservice"
}

// /v1/fields/featureservice/{datasetId}
module "v1_fields_featureservice_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_fields_featureservice_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/rest-datasets/featureservice
module "v1_rest_datasets_featureservice_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_rest_datasets_resource.id
  path_part   = "featureservice"
}

// /v1/rest-datasets/featureservice/{datasetId}
module "v1_rest_datasets_featureservice_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_rest_datasets_featureservice_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

module "arcgis_get_v1_query_featureservice_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_query_featureservice_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30502/api/v1/arcgis/query/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "arcgis_post_v1_query_featureservice_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_query_featureservice_dataset_id_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30502/api/v1/arcgis/query/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "arcgis_get_v1_download_featureservice_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_download_featureservice_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30502/api/v1/arcgis/download/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "arcgis_post_v1_download_featureservice_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_download_featureservice_dataset_id_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30502/api/v1/arcgis/download/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "arcgis_get_v1_fields_featureservice_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_fields_featureservice_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30502/api/v1/arcgis/fields/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "arcgis_post_v1_rest_datasets_featureservice" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_rest_datasets_featureservice_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30502/api/v1/arcgis/rest-datasets/featureservice"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "arcgis_delete_v1_rest_datasets_featureservice_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.v1_rest_datasets_featureservice_dataset_id_resource.aws_api_gateway_resource
  method          = "DELETE"
  uri             = "http://${local.api_gateway_target_url}:30502/api/v1/arcgis/rest-datasets/featureservice/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}
