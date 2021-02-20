
resource "kubernetes_service" "doc_orchestrator_service" {
  metadata {
    name = "doc-orchestrator"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                 = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=doc-orchestrator"
    }
  }
  spec {
    selector = {
      name = "doc-orchestrator"
    }
    port {
      port        = 80
      target_port = 5000
    }

    type = "LoadBalancer"
  }
}

data "aws_lb" "doc_orchestrator_lb" {
  name = split("-", kubernetes_service.doc_orchestrator_service.status.0.load_balancer.0.ingress.0.hostname).0

  depends_on = [
    kubernetes_service.doc_orchestrator_service
  ]
}

resource "aws_api_gateway_vpc_link" "doc_orchestrator_lb_vpc_link" {
  name        = "Doc Orchestrator LB VPC link"
  description = "VPC link to the doc_orchestrator service load balancer"
  target_arns = [data.aws_lb.doc_orchestrator_lb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v1/doc-importer
resource "aws_api_gateway_resource" "doc_importer_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "doc-importer"
}

// /v1/doc-importer/task
resource "aws_api_gateway_resource" "doc_importer_task_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.doc_importer_resource.id
  path_part   = "task"
}

// /v1/doc-importer/task/{taskId}
resource "aws_api_gateway_resource" "doc_importer_task_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.doc_importer_task_resource.id
  path_part   = "{taskId}"
}

module "doc_orchestrator_get_doc_importer_task" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.doc_importer_task_resource
  method         = "GET"
  uri            = "http://api.resourcewatch.org/api/v1/doc-importer/task"
  vpc_link       = aws_api_gateway_vpc_link.doc_orchestrator_lb_vpc_link
}

module "doc_orchestrator_get_doc_importer_task_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.doc_importer_task_id_resource
  method         = "GET"
  uri            = "http://api.resourcewatch.org/api/v1/doc-importer/task/{taskId}"
  vpc_link       = aws_api_gateway_vpc_link.doc_orchestrator_lb_vpc_link
}

module "doc_orchestrator_delete_doc_importer_task_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.doc_importer_task_id_resource
  method         = "DELETE"
  uri            = "http://api.resourcewatch.org/api/v1/doc-importer/task/{taskId}"
  vpc_link       = aws_api_gateway_vpc_link.doc_orchestrator_lb_vpc_link
}