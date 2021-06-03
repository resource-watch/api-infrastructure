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

data "aws_lb" "load_balancer" {
  arn  = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "bigquery_nlb_listener" {
  load_balancer_arn = data.aws_lb.load_balancer.arn
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

// /v1/query/bigquery
module "v1_query_bigquery_resource" {
  source       = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_query_resource.id
  path_part   = "bigquery"
}

// /v1/query/bigquery/{datasetId}
module "v1_query_bigquery_dataset_id_resource" {
  source       = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_query_bigquery_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/download/bigquery
module "v1_download_bigquery_resource" {
  source       = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_download_resource.id
  path_part   = "bigquery"
}

// /v1/download/bigquery/{datasetId}
module "v1_download_bigquery_dataset_id_resource" {
  source       = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_download_bigquery_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields/bigquery
module "v1_fields_bigquery_resource" {
  source       = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_fields_resource.id
  path_part   = "bigquery"
}

// /v1/fields/bigquery/{datasetId}
module "v1_fields_bigquery_dataset_id_resource" {
  source       = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_fields_bigquery_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/rest-datasets/bigquery
module "v1_rest_datasets_bigquery_resource" {
  source       = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_rest_datasets_resource.id
  path_part   = "bigquery"
}

module "bigquery_get_v1_query_bigquery_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = module.v1_query_bigquery_dataset_id_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30506/api/v1/bigquery/query/{datasetId}"
  vpc_link     = var.vpc_link
}

module "bigquery_post_v1_query_bigquery_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = module.v1_query_bigquery_dataset_id_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30506/api/v1/bigquery/query/{datasetId}"
  vpc_link     = var.vpc_link
}

module "bigquery_get_v1_download_bigquery_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = module.v1_download_bigquery_dataset_id_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30506/api/v1/bigquery/download/{datasetId}"
  vpc_link     = var.vpc_link
}

module "bigquery_post_v1_download_bigquery_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = module.v1_download_bigquery_dataset_id_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30506/api/v1/bigquery/download/{datasetId}"
  vpc_link     = var.vpc_link
}

module "bigquery_get_v1_fields_bigquery_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = module.v1_fields_bigquery_dataset_id_resource.aws_api_gateway_resource
  method       = "GET"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30506/api/v1/bigquery/fields/{datasetId}"
  vpc_link     = var.vpc_link
}

module "bigquery_post_v1_rest_datasets_bigquery" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = module.v1_rest_datasets_bigquery_resource.aws_api_gateway_resource
  method       = "POST"
  uri          = "http://${data.aws_lb.load_balancer.dns_name}:30506/api/v1/bigquery/rest-datasets/bigquery"
  vpc_link     = var.vpc_link
}

