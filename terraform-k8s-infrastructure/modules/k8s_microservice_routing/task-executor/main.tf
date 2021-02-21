resource "kubernetes_service" "task_async_service" {
  metadata {
    name      = "task-async"
    namespace = "default"

  }
  spec {
    selector = {
      name = "task-async"
    }
    port {
      port        = 30562
      node_port   = 30562
      target_port = 5005
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "task_async_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30562
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.task_async_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "task_async_lb_target_group" {
  name        = "task-async-lb-tg"
  port        = 30562
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_task_async" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.task_async_lb_target_group.arn
}

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v1/task
resource "aws_api_gateway_resource" "task_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
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
  uri          = "http://api.resourcewatch.org:30562/api/v1/task"
  vpc_link     = var.vpc_link
}

module "task_async_post_task_sync_dataset" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.task_sync_dataset_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30562/api/v1/task/sync-dataset"
  vpc_link     = var.vpc_link
}

module "task_async_put_task_sync_dataset_by_dataset" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.task_sync_dataset_by_dataset_resource
  method       = "PUT"
  uri          = "http://api.resourcewatch.org:30562/api/v1/task/sync-dataset/by-dataset"
  vpc_link     = var.vpc_link
}

module "task_async_delete_task_sync_dataset_by_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.task_sync_dataset_by_dataset_id_resource
  method       = "DELETE"
  uri          = "http://api.resourcewatch.org:30562/api/v1/task/sync-dataset/by-dataset/{datasetId}"
  vpc_link     = var.vpc_link
}

module "task_async_post_task_sync_dataset_by_dataset_id_hook" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.task_sync_dataset_by_dataset_id_hook_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30562/api/v1/task/sync-dataset/by-dataset/{datasetId}/hook"
  vpc_link     = var.vpc_link
}

