provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

resource "kubernetes_service" "task_async_service" {
  metadata {
    name      = "task-async"
    namespace = "default"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                 = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=task-async"
    }
  }
  spec {
    selector = {
      name = "task-async"
    }
    port {
      port        = 80
      target_port = 5005
    }

    type = "LoadBalancer"
  }
}

data "aws_lb" "task_async_lb" {
  name = split("-", kubernetes_service.task_async_service.status.0.load_balancer.0.ingress.0.hostname).0

  depends_on = [
    kubernetes_service.task_async_service
  ]
}

resource "aws_api_gateway_vpc_link" "task_async_lb_vpc_link" {
  name        = "Task async LB VPC link"
  description = "VPC link to the Task_async service load balancer"
  target_arns = [data.aws_lb.task_async_lb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

// /v1/task
resource "aws_api_gateway_resource" "task_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.resource_root_id
  path_part   = "task"
}

// /v1/task/sync-dataset
resource "aws_api_gateway_resource" "task_sync_dataset_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.task_resource.id
  path_part   = "sync-dataset"
}

// /v1/task/sync-dataset/by-dataset
resource "aws_api_gateway_resource" "task_sync_dataset_by_dataset_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.task_sync_dataset_resource.id
  path_part   = "by-dataset"
}

// /v1/task/sync-dataset/by-dataset/{datasetId}
resource "aws_api_gateway_resource" "task_sync_dataset_by_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.task_sync_dataset_by_dataset_resource.id
  path_part   = "{datasetId}"
}

// /v1/task/sync-dataset/by-dataset/{datasetId}/hook
resource "aws_api_gateway_resource" "task_sync_dataset_by_dataset_id_hook_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.task_sync_dataset_by_dataset_id_resource.id
  path_part   = "hook"
}

module "task_async_get_task" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.task_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/task"
  vpc_link     = aws_api_gateway_vpc_link.task_async_lb_vpc_link
}

module "task_async_post_task_sync_dataset" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.task_sync_dataset_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/task/sync-dataset"
  vpc_link     = aws_api_gateway_vpc_link.task_async_lb_vpc_link
}

module "task_async_put_task_sync_dataset_by_dataset" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.task_sync_dataset_by_dataset_resource
  method       = "PUT"
  uri          = "http://api.resourcewatch.org/api/v1/task/sync-dataset/by-dataset"
  vpc_link     = aws_api_gateway_vpc_link.task_async_lb_vpc_link
}

module "task_async_delete_task_sync_dataset_by_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.task_sync_dataset_by_dataset_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org/api/v1/task/sync-dataset/by-dataset/{datasetId}"
  vpc_link     = aws_api_gateway_vpc_link.task_async_lb_vpc_link
}

module "task_async_post_task_sync_dataset_by_dataset_id_hook" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.task_sync_dataset_by_dataset_id_hook_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/task/sync-dataset/by-dataset/{datasetId}/hook"
  vpc_link     = aws_api_gateway_vpc_link.task_async_lb_vpc_link
}

