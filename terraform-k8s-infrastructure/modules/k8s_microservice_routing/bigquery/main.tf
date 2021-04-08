resource "kubernetes_service" "bigquery_service" {
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

resource "aws_lb_listener" "bigquery_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30506
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bigquery_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "bigquery_lb_target_group" {
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
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.bigquery_lb_target_group.arn
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

// /v1/query/bigquery
resource "aws_api_gateway_resource" "v1_query_bigquery_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_query_resource.id
  path_part   = "bigquery"
}

// /v1/query/bigquery/{datasetId}
resource "aws_api_gateway_resource" "v1_query_bigquery_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_query_bigquery_resource.id
  path_part   = "{datasetId}"
}

// /v1/download/bigquery
resource "aws_api_gateway_resource" "v1_download_bigquery_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_download_resource.id
  path_part   = "bigquery"
}

// /v1/download/bigquery/{datasetId}
resource "aws_api_gateway_resource" "v1_download_bigquery_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_download_bigquery_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields/bigquery
resource "aws_api_gateway_resource" "v1_fields_bigquery_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_fields_resource.id
  path_part   = "bigquery"
}

// /v1/fields/bigquery/{datasetId}
resource "aws_api_gateway_resource" "v1_fields_bigquery_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_fields_bigquery_resource.id
  path_part   = "{datasetId}"
}

// /v1/rest-datasets/bigquery
resource "aws_api_gateway_resource" "v1_rest_datasets_bigquery_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_rest_datasets_resource.id
  path_part   = "bigquery"
}

module "bigquery_get_v1_query_bigquery_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_query_bigquery_dataset_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30506/api/v1/bigquery/query/{datasetId}"
  vpc_link     = var.vpc_link
}

module "bigquery_post_v1_query_bigquery_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_query_bigquery_dataset_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30506/api/v1/bigquery/query/{datasetId}"
  vpc_link     = var.vpc_link
}

module "bigquery_get_v1_download_bigquery_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_download_bigquery_dataset_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30506/api/v1/bigquery/download/{datasetId}"
  vpc_link     = var.vpc_link
}

module "bigquery_post_v1_download_bigquery_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_download_bigquery_dataset_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30506/api/v1/bigquery/download/{datasetId}"
  vpc_link     = var.vpc_link
}

module "bigquery_get_v1_fields_bigquery_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_fields_bigquery_dataset_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30506/api/v1/bigquery/fields/{datasetId}"
  vpc_link     = var.vpc_link
}

module "bigquery_post_v1_rest_datasets_bigquery" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_rest_datasets_bigquery_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30506/api/v1/bigquery/rest-datasets/bigquery"
  vpc_link     = var.vpc_link
}

