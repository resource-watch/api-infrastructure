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

// /v1/task
resource "aws_api_gateway_resource" "task_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "task"
}

// /v1/task/{proxy+}
resource "aws_api_gateway_resource" "task_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.task_resource.id
  path_part   = "{proxy+}"
}

module "task_async_get_task" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.task_resource
  method       = "GET"
  uri          = "http://${var.load_balancer.dns_name}:30562/api/v1/task"
  vpc_link     = var.vpc_link
}

module "task_async_any_task_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.task_proxy_resource
  method       = "ANY"
  uri          = "http://${var.load_balancer.dns_name}:30562/api/v1/task/{proxy}"
  vpc_link     = var.vpc_link
}

