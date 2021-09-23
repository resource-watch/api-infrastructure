resource "kubernetes_service" "nexgddp_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  metadata {
    name      = "nexgddp"
    namespace = "prep"

  }
  spec {
    selector = {
      name = "nexgddp"
    }
    port {
      port        = 30549
      node_port   = 30549
      target_port = 3078
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

resource "aws_lb_listener" "nexgddp_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30549
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nexgddp_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "nexgddp_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  name        = "nexgddp-lb-tg"
  port        = 30549
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_nexgddp" {
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.nexgddp_lb_target_group[0].arn
}

// /v1/nexgddp
module "nexgddp_v1_nexgddp_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "nexgddp"
}

// /v1/nexgddp/{proxy+}
module "nexgddp_v1_nexgddp_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.nexgddp_v1_nexgddp_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/query/nexgddp
module "nexgddp_v1_query_nexgddp_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_query_resource.id
  path_part   = "nexgddp"
}

// /v1/query/nexgddp/{datasetId}
module "nexgddp_v1_query_nexgddp_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.nexgddp_v1_query_nexgddp_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/download/nexgddp
module "nexgddp_v1_download_nexgddp_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_download_resource.id
  path_part   = "nexgddp"
}

// /v1/download/nexgddp/{datasetId}
module "nexgddp_v1_download_nexgddp_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.nexgddp_v1_download_nexgddp_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields/nexgddp
module "nexgddp_v1_fields_nexgddp_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_fields_resource.id
  path_part   = "nexgddp"
}

// /v1/fields/nexgddp/{datasetId}
module "nexgddp_v1_fields_nexgddp_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.nexgddp_v1_fields_nexgddp_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/rest-datasets/nexgddp
module "nexgddp_v1_rest_datasets_nexgddp_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_rest_datasets_resource.id
  path_part   = "nexgddp"
}

// /v1/rest-datasets/nexgddp/{datasetId}
module "nexgddp_v1_rest_datasets_nexgddp_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.nexgddp_v1_rest_datasets_nexgddp_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/layer/{layerId}/tile/nexgddp
module "nexgddp_v1_layer_id_tile_nexgddp_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_layer_id_tile_resource.id
  path_part   = "nexgddp"
}

// /v1/layer/{layerId}/tile/nexgddp/{proxy+}
module "nexgddp_v1_layer_id_tile_nexgddp_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.nexgddp_v1_layer_id_tile_nexgddp_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/layer/{layerId}/tile/loca
module "nexgddp_v1_layer_id_tile_loca_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_layer_id_tile_resource.id
  path_part   = "loca"
}

// /v1/layer/{layerId}/tile/loca/{proxy+}
module "nexgddp_v1_layer_id_tile_loca_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.nexgddp_v1_layer_id_tile_loca_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/layer/nexgddp
module "nexgddp_layer_nexgddp_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_layer_resource.id
  path_part   = "nexgddp"
}

// /v1/layer/nexgddp/{proxy+}
module "nexgddp_layer_nexgddp_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.nexgddp_layer_nexgddp_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/layer/loca
module "loca_layer_loca_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_layer_resource.id
  path_part   = "loca"
}

// /v1/layer/loca/{proxy+}
module "nexgddp_layer_loca_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.loca_layer_loca_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/query/loca
module "nexgddp_v1_query_loca_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_query_resource.id
  path_part   = "loca"
}

// /v1/query/loca/{datasetId}
module "nexgddp_v1_query_loca_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.nexgddp_v1_query_loca_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields/loca
module "nexgddp_v1_fields_loca_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_fields_resource.id
  path_part   = "loca"
}

// /v1/fields/loca/{datasetId}
module "nexgddp_v1_fields_loca_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.nexgddp_v1_fields_loca_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/rest-datasets/loca
module "nexgddp_v1_rest_datasets_loca_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_rest_datasets_resource.id
  path_part   = "loca"
}

// /v1/loca
module "nexgddp_v1_loca_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "loca"
}

// /v1/loca/{proxy+}
module "nexgddp_v1_loca_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.nexgddp_v1_loca_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "nexgddp_get_v1_query_nexgddp_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.nexgddp_v1_query_nexgddp_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30549/api/v1/nexgddp/query/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "nexgddp_post_v1_query_nexgddp_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.nexgddp_v1_query_nexgddp_dataset_id_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30549/api/v1/nexgddp/query/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "nexgddp_get_v1_fields_nexgddp_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.nexgddp_v1_fields_nexgddp_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30549/api/v1/nexgddp/fields/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "nexgddp_post_v1_rest_datasets_nexgddp" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.nexgddp_v1_rest_datasets_nexgddp_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30549/api/v1/nexgddp/rest-datasets/nexgddp"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "nexgddp_delete_v1_rest_datasets_nexgddp_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.nexgddp_v1_rest_datasets_nexgddp_dataset_id_resource.aws_api_gateway_resource
  method          = "DELETE"
  uri             = "http://${local.api_gateway_target_url}:30549/api/v1/nexgddp/rest-datasets/nexgddp/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "nexgddp_get_v1_query_loca_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.nexgddp_v1_query_loca_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30549/api/v1/nexgddp/query/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "nexgddp_post_v1_query_loca_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.nexgddp_v1_query_loca_dataset_id_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30549/api/v1/nexgddp/query/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "nexgddp_get_v1_fields_loca_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.nexgddp_v1_fields_loca_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30549/api/v1/nexgddp/fields/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "nexgddp_post_v1_rest_datasets_loca" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.nexgddp_v1_rest_datasets_loca_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30549/api/v1/nexgddp/rest-datasets/nexgddp"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "nexgddp_any_v1_nexgddp_proxy" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.nexgddp_v1_nexgddp_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30549/api/v1/nexgddp/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "nexgddp_any_v1_loca_proxy" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.nexgddp_v1_loca_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30549/api/v1/nexgddp/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "gee_tiles_any_layer_id_tile_nexgddp_proxy_resource" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.nexgddp_v1_layer_id_tile_nexgddp_proxy_resource.aws_api_gateway_resource
  method                      = "ANY"
  uri                         = "http://${local.api_gateway_target_url}:30549/api/v1/nexgddp/layer/{layerId}/tile/nexgddp/{proxy}"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["layerId"]
}

module "gee_tiles_any_layer_id_tile_loca_proxy_resource" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.nexgddp_v1_layer_id_tile_loca_proxy_resource.aws_api_gateway_resource
  method                      = "ANY"
  uri                         = "http://${local.api_gateway_target_url}:30549/api/v1/nexgddp/layer/{layerId}/tile/nexgddp/{proxy}"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["layerId"]
}

module "gee_tiles_any_layer_nexgddp_proxy_resource" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.nexgddp_layer_nexgddp_proxy_resource.aws_api_gateway_resource
  method                      = "ANY"
  uri                         = "http://${local.api_gateway_target_url}:30549/api/v1/nexgddp/layer/nexgddp/{proxy}"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["layerId"]
}

module "gee_tiles_any_layer_loca_proxy_resource" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.nexgddp_layer_loca_proxy_resource.aws_api_gateway_resource
  method                      = "ANY"
  uri                         = "http://${local.api_gateway_target_url}:30549/api/v1/nexgddp/layer/nexgddp/{proxy}"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["layerId"]
}
