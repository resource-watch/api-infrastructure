resource "kubernetes_service" "nexgddp_service" {
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

resource "aws_lb_listener" "nexgddp_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30549
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nexgddp_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "nexgddp_lb_target_group" {
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
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.nexgddp_lb_target_group.arn
}

// /v1
data "aws_api_gateway_resource" "nexgddp_v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v1/query
data "aws_api_gateway_resource" "nexgddp_v1_query_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/query"
}

// /v1/download
data "aws_api_gateway_resource" "nexgddp_v1_download_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/download"
}

// /v1/fields
data "aws_api_gateway_resource" "nexgddp_v1_fields_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/fields"
}

// /v1/rest-datasets
data "aws_api_gateway_resource" "nexgddp_v1_rest_datasets_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/rest-datasets"
}

// /v1/layer
data "aws_api_gateway_resource" "layer" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/layer"
}

// /v1/layer/{layerId}
data "aws_api_gateway_resource" "nexgddp_v1_layer_id" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/layer/{layerId}"
}
// /v1/layer/{layerId}
data "aws_api_gateway_resource" "nexgddp_v1_layer_id_tile" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/layer/{layerId}/tile"
}

// /v1/nexgddp
resource "aws_api_gateway_resource" "nexgddp_v1_nexgddp_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.nexgddp_v1_resource.id
  path_part   = "nexgddp"
}

// /v1/nexgddp/{proxy+}
resource "aws_api_gateway_resource" "nexgddp_v1_nexgddp_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.nexgddp_v1_nexgddp_resource.id
  path_part   = "{proxy+}"
}

// /v1/query/nexgddp
resource "aws_api_gateway_resource" "nexgddp_v1_query_nexgddp_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.nexgddp_v1_query_resource.id
  path_part   = "nexgddp"
}

// /v1/query/nexgddp/{datasetId}
resource "aws_api_gateway_resource" "nexgddp_v1_query_nexgddp_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.nexgddp_v1_query_nexgddp_resource.id
  path_part   = "{datasetId}"
}

// /v1/download/nexgddp
resource "aws_api_gateway_resource" "nexgddp_v1_download_nexgddp_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.nexgddp_v1_download_resource.id
  path_part   = "nexgddp"
}

// /v1/download/nexgddp/{datasetId}
resource "aws_api_gateway_resource" "nexgddp_v1_download_nexgddp_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.nexgddp_v1_download_nexgddp_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields/nexgddp
resource "aws_api_gateway_resource" "nexgddp_v1_fields_nexgddp_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.nexgddp_v1_fields_resource.id
  path_part   = "nexgddp"
}

// /v1/fields/nexgddp/{datasetId}
resource "aws_api_gateway_resource" "nexgddp_v1_fields_nexgddp_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.nexgddp_v1_fields_nexgddp_resource.id
  path_part   = "{datasetId}"
}

// /v1/rest-datasets/nexgddp
resource "aws_api_gateway_resource" "nexgddp_v1_rest_datasets_nexgddp_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.nexgddp_v1_rest_datasets_resource.id
  path_part   = "nexgddp"
}

// /v1/rest-datasets/nexgddp/{datasetId}
resource "aws_api_gateway_resource" "nexgddp_v1_rest_datasets_nexgddp_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.nexgddp_v1_rest_datasets_nexgddp_resource.id
  path_part   = "{datasetId}"
}

// /v1/layer/{layerId}/tile/nexgddp
resource "aws_api_gateway_resource" "nexgddp_v1_layer_id_tile_nexgddp_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.nexgddp_v1_layer_id_tile.id
  path_part   = "nexgddp"
}

// /v1/layer/{layerId}/tile/nexgddp/{proxy+}
resource "aws_api_gateway_resource" "nexgddp_v1_layer_id_tile_nexgddp_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.nexgddp_v1_layer_id_tile_nexgddp_resource.id
  path_part   = "{proxy+}"
}

// /v1/layer/{layerId}/tile/loca
resource "aws_api_gateway_resource" "nexgddp_v1_layer_id_tile_loca_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.nexgddp_v1_layer_id_tile.id
  path_part   = "loca"
}

// /v1/layer/{layerId}/tile/loca/{proxy+}
resource "aws_api_gateway_resource" "nexgddp_v1_layer_id_tile_loca_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.nexgddp_v1_layer_id_tile_loca_resource.id
  path_part   = "{proxy+}"
}

// /v1/layer/nexgddp
resource "aws_api_gateway_resource" "nexgddp_layer_nexgddp_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.layer.id
  path_part   = "nexgddp"
}

// /v1/layer/nexgddp/{proxy+}
resource "aws_api_gateway_resource" "nexgddp_layer_nexgddp_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.nexgddp_layer_nexgddp_resource.id
  path_part   = "{proxy+}"
}

// /v1/layer/loca
resource "aws_api_gateway_resource" "loca_layer_loca_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.layer.id
  path_part   = "loca"
}

// /v1/layer/loca/{proxy+}
resource "aws_api_gateway_resource" "nexgddp_layer_loca_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.loca_layer_loca_resource.id
  path_part   = "{proxy+}"
}

// /v1/query/loca
resource "aws_api_gateway_resource" "nexgddp_v1_query_loca_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.nexgddp_v1_query_resource.id
  path_part   = "loca"
}

// /v1/query/loca/{datasetId}
resource "aws_api_gateway_resource" "nexgddp_v1_query_loca_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.nexgddp_v1_query_loca_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields/loca
resource "aws_api_gateway_resource" "nexgddp_v1_fields_loca_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.nexgddp_v1_fields_resource.id
  path_part   = "loca"
}

// /v1/fields/loca/{datasetId}
resource "aws_api_gateway_resource" "nexgddp_v1_fields_loca_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.nexgddp_v1_fields_loca_resource.id
  path_part   = "{datasetId}"
}

// /v1/rest-datasets/loca
resource "aws_api_gateway_resource" "nexgddp_v1_rest_datasets_loca_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.nexgddp_v1_rest_datasets_resource.id
  path_part   = "loca"
}

// /v1/loca
resource "aws_api_gateway_resource" "nexgddp_v1_loca_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.nexgddp_v1_resource.id
  path_part   = "loca"
}

// /v1/loca/{proxy+}
resource "aws_api_gateway_resource" "nexgddp_v1_loca_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.nexgddp_v1_loca_resource.id
  path_part   = "{proxy+}"
}

module "nexgddp_get_v1_query_nexgddp_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.nexgddp_v1_query_nexgddp_dataset_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30549/api/v1/nexgddp/query/{datasetId}"
  vpc_link     = var.vpc_link
}

module "nexgddp_post_v1_query_nexgddp_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.nexgddp_v1_query_nexgddp_dataset_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30549/api/v1/nexgddp/query/{datasetId}"
  vpc_link     = var.vpc_link
}

module "nexgddp_get_v1_fields_nexgddp_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.nexgddp_v1_fields_nexgddp_dataset_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30549/api/v1/nexgddp/fields/{datasetId}"
  vpc_link     = var.vpc_link
}

module "nexgddp_post_v1_rest_datasets_nexgddp" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.nexgddp_v1_rest_datasets_nexgddp_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30549/api/v1/nexgddp/rest-datasets/nexgddp"
  vpc_link     = var.vpc_link
}

module "nexgddp_delete_v1_rest_datasets_nexgddp_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.nexgddp_v1_rest_datasets_nexgddp_dataset_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30549/api/v1/nexgddp/rest-datasets/nexgddp/{datasetId}"
  vpc_link     = var.vpc_link
}

module "nexgddp_get_v1_query_loca_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.nexgddp_v1_query_loca_dataset_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30549/api/v1/nexgddp/query/{datasetId}"
  vpc_link     = var.vpc_link
}

module "nexgddp_post_v1_query_loca_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.nexgddp_v1_query_loca_dataset_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30549/api/v1/nexgddp/query/{datasetId}"
  vpc_link     = var.vpc_link
}

module "nexgddp_get_v1_fields_loca_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.nexgddp_v1_fields_loca_dataset_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30549/api/v1/nexgddp/fields/{datasetId}"
  vpc_link     = var.vpc_link
}

module "nexgddp_post_v1_rest_datasets_loca" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.nexgddp_v1_rest_datasets_loca_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30549/api/v1/nexgddp/rest-datasets/nexgddp"
  vpc_link     = var.vpc_link
}

module "nexgddp_any_v1_nexgddp_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.nexgddp_v1_nexgddp_proxy_resource
  method       = "ANY"
  uri          = "http://api.resourcewatch.org:30549/api/v1/nexgddp/{proxy}"
  vpc_link     = var.vpc_link
}

module "nexgddp_any_v1_loca_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.nexgddp_v1_loca_proxy_resource
  method       = "ANY"
  uri          = "http://api.resourcewatch.org:30549/api/v1/nexgddp/{proxy}"
  vpc_link     = var.vpc_link
}

module "gee_tiles_any_layer_id_tile_nexgddp_proxy_resource" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.nexgddp_v1_layer_id_tile_nexgddp_proxy_resource
  method                      = "ANY"
  uri                         = "http://api.resourcewatch.org:30549/api/v1/nexgddp/layer/{layerId}/tile/nexgddp/{proxy}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["layerId"]
}

module "gee_tiles_any_layer_id_tile_loca_proxy_resource" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.nexgddp_v1_layer_id_tile_loca_proxy_resource
  method                      = "ANY"
  uri                         = "http://api.resourcewatch.org:30549/api/v1/nexgddp/layer/{layerId}/tile/nexgddp/{proxy}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["layerId"]
}

module "gee_tiles_any_layer_nexgddp_proxy_resource" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.nexgddp_layer_nexgddp_proxy_resource
  method                      = "ANY"
  uri                         = "http://api.resourcewatch.org:30549/api/v1/nexgddp/layer/nexgddp/{proxy}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["layerId"]
}

module "gee_tiles_any_layer_loca_proxy_resource" {
  source                      = "../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.nexgddp_layer_loca_proxy_resource
  method                      = "ANY"
  uri                         = "http://api.resourcewatch.org:30549/api/v1/nexgddp/layer/nexgddp/{proxy}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["layerId"]
}
