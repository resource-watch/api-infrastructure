provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

resource "kubernetes_service" "webshot_service" {
  metadata {
    name      = "webshot"
    namespace = "default"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                 = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=webshot"
    }
  }
  spec {
    selector = {
      name = "webshot"
    }
    port {
      port        = 80
      target_port = 5000
    }

    type = "LoadBalancer"
  }
}

data "aws_lb" "webshot_lb" {
  name = split("-", kubernetes_service.webshot_service.status.0.load_balancer.0.ingress.0.hostname).0

  depends_on = [
    kubernetes_service.webshot_service
  ]
}

resource "aws_api_gateway_vpc_link" "webshot_lb_vpc_link" {
  name        = "webshot LB VPC link"
  description = "VPC link to the webshot service load balancer"
  target_arns = [data.aws_lb.webshot_lb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

// /api/v1/webshot
resource "aws_api_gateway_resource" "webshot_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.resource_root_id
  path_part   = "webshot"
}

// /api/v1/webshot/pdf
resource "aws_api_gateway_resource" "webshot_pdf_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.webshot_resource.id
  path_part   = "pdf"
}

// /api/v1/webshot/widget
resource "aws_api_gateway_resource" "webshot_widget_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.webshot_resource.id
  path_part   = "widget"
}

// /api/v1/webshot/{widgetId}
resource "aws_api_gateway_resource" "webshot_widget_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.webshot_widget_resource.id
  path_part   = "{widgetId}"
}

// /api/v1/webshot/{widgetId}/thumbnail
resource "aws_api_gateway_resource" "webshot_widget_id_thumbnail_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.webshot_widget_id_resource.id
  path_part   = "thumbnail"
}

module "webshot_pdf" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.webshot_pdf_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/webshot"
  vpc_link     = aws_api_gateway_vpc_link.webshot_lb_vpc_link
}

module "webshot_widget_id_thumbnail" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.webshot_widget_id_thumbnail_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/webshot/widget/{widgetId}/thumbnail"
  vpc_link     = aws_api_gateway_vpc_link.webshot_lb_vpc_link
}