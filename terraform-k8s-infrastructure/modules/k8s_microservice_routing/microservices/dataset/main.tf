resource "kubernetes_service" "dataset_service" {
  metadata {
    name      = "dataset"
    namespace = "default"
  }
  spec {
    selector = {
      name = "dataset"
    }
    port {
      port        = 30516
      node_port   = 30516
      target_port = 3000
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "dataset_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30516
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dataset_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "dataset_lb_target_group" {
  name        = "dataset-lb-tg"
  port        = 30516
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_dataset" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.dataset_lb_target_group.arn
}

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v1/dataset
resource "aws_api_gateway_resource" "dataset_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "dataset"
}

// /v1/rest-datasets
resource "aws_api_gateway_resource" "rest_datasets_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "rest-datasets"
}

// /v1/dataset/{datasetId}
resource "aws_api_gateway_resource" "dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_resource.id
  path_part   = "{datasetId}"
}

// /v1/dataset/find-by-ids
resource "aws_api_gateway_resource" "dataset_find_by_ids_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_resource.id
  path_part   = "find-by-ids"
}

// /v1/dataset/upload
resource "aws_api_gateway_resource" "dataset_upload_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_resource.id
  path_part   = "upload"
}

// /v1/dataset/{datasetId}/clone
resource "aws_api_gateway_resource" "dataset_clone_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_resource.id
  path_part   = "clone"
}

// /v1/dataset/{datasetId}/flush
resource "aws_api_gateway_resource" "dataset_flush_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_resource.id
  path_part   = "flush"
}

// /v1/dataset/{datasetId}/recover
resource "aws_api_gateway_resource" "dataset_recover_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_resource.id
  path_part   = "recover"
}

// /v1/dataset/{datasetId}/lastUpdated
resource "aws_api_gateway_resource" "dataset_last_updated_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.dataset_id_resource.id
  path_part   = "lastUpdated"
}

module "dataset_get_dataset" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30516/api/v1/dataset"
  vpc_link     = var.vpc_link
}

module "dataset_get_dataset_id" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30516/api/v1/dataset/{datasetId}"
  vpc_link     = var.vpc_link
}

module "dataset_update_dataset_id" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_resource
  method       = "PATCH"
  uri          = "http://api.resourcewatch.org:30516/api/v1/dataset/{datasetId}"
  vpc_link     = var.vpc_link
}

module "dataset_delete_dataset_id" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30516/api/v1/dataset/{datasetId}"
  vpc_link     = var.vpc_link
}

module "dataset_post_dataset" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30516/api/v1/dataset"
  vpc_link     = var.vpc_link
}

module "dataset_post_dataset_id_clone" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_clone_resource
  method                      = "POST"
  uri                         = "http://api.resourcewatch.org:30516/api/v1/dataset/{datasetId}/clone"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "dataset_post_dataset_id_flush" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_flush_resource
  method                      = "POST"
  uri                         = "http://api.resourcewatch.org:30516/api/v1/dataset/{datasetId}/flush"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "dataset_post_dataset_id_recover" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_recover_resource
  method                      = "POST"
  uri                         = "http://api.resourcewatch.org:30516/api/v1/dataset/{datasetId}/recover"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "dataset_get_dataset_id_last_updated" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.dataset_last_updated_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30516/api/v1/dataset/{datasetId}/lastUpdated"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "dataset_post_dataset_find_by_ids" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30516/api/v1/dataset/find-by-ids"
  vpc_link     = var.vpc_link
}

module "dataset_post_dataset_upload" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_upload_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30516/api/v1/dataset/upload"
  vpc_link     = var.vpc_link
}
