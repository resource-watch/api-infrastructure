resource "kubernetes_service" "carto_service" {
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

resource "aws_lb_listener" "carto_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30507
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.carto_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "carto_lb_target_group" {
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
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.carto_lb_target_group.arn
}

// /v1/query
data "aws_api_gateway_resource" "v1_query_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/query"
}

// /v1/download
data "aws_api_gateway_resource" "v1_download_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/download"
}

// /v1/fields
data "aws_api_gateway_resource" "v1_fields_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/fields"
}

// /v1/rest-datasets
data "aws_api_gateway_resource" "v1_rest_datasets_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/rest-datasets"
}

// /v1/query/cartodb
resource "aws_api_gateway_resource" "v1_query_cartodb_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_query_resource.id
  path_part   = "cartodb"
}

// /v1/query/cartodb/{datasetId}
resource "aws_api_gateway_resource" "v1_query_cartodb_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_query_cartodb_resource.id
  path_part   = "{datasetId}"
}

// /v1/download/cartodb
resource "aws_api_gateway_resource" "v1_download_cartodb_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_download_resource.id
  path_part   = "cartodb"
}

// /v1/download/cartodb/{datasetId}
resource "aws_api_gateway_resource" "v1_download_cartodb_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_download_cartodb_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields/cartodb
resource "aws_api_gateway_resource" "v1_fields_cartodb_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_fields_resource.id
  path_part   = "cartodb"
}

// /v1/fields/cartodb/{datasetId}
resource "aws_api_gateway_resource" "v1_fields_cartodb_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_fields_cartodb_resource.id
  path_part   = "{datasetId}"
}

// /v1/rest-datasets/cartodb
resource "aws_api_gateway_resource" "v1_rest_datasets_cartodb_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_rest_datasets_resource.id
  path_part   = "cartodb"
}

// /v1/rest-datasets/cartodb/{datasetId}
resource "aws_api_gateway_resource" "v1_rest_datasets_cartodb_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_rest_datasets_cartodb_resource.id
  path_part   = "{datasetId}"
}

module "carto_get_v1_query_cartodb_dataset_id" {
  source         = "../../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.v1_query_cartodb_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org:30507/api/v1/carto/query/{datasetId}"
  vpc_link       = var.vpc_link
}

module "carto_post_v1_query_cartodb_dataset_id" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_query_cartodb_dataset_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30507/api/v1/carto/query/{datasetId}"
  vpc_link     = var.vpc_link
}

module "carto_get_v1_download_cartodb_dataset_id" {
  source         = "../../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.v1_download_cartodb_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org:30507/api/v1/carto/download/{datasetId}"
  vpc_link       = var.vpc_link
}

module "carto_post_v1_download_cartodb_dataset_id" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_download_cartodb_dataset_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30507/api/v1/carto/download/{datasetId}"
  vpc_link     = var.vpc_link
}

module "carto_get_v1_fields_cartodb_dataset_id" {
  source         = "../../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.v1_fields_cartodb_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org:30507/api/v1/carto/fields/{datasetId}"
  vpc_link       = var.vpc_link
}

module "carto_post_v1_rest_datasets_cartodb" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_rest_datasets_cartodb_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30507/api/v1/carto/rest-datasets/cartodb"
  vpc_link     = var.vpc_link
}

module "carto_delete_v1_rest_datasets_cartodb_dataset_id" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_rest_datasets_cartodb_dataset_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30502/api/v1/carto/rest-datasets/cartodb/{datasetId}"
  vpc_link     = var.vpc_link
}


