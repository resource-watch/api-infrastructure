provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

resource "kubernetes_service" "control_tower_service" {
  metadata {
    name      = "control-tower"
    namespace = "gateway"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                 = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=control-tower"
    }
  }
  spec {
    selector = {
      name = "control-tower"
    }
    port {
      port        = 80
      target_port = 9000
    }

    type = "LoadBalancer"
  }
}

data "aws_lb" "control_tower_lb" {
  name = split("-", kubernetes_service.control_tower_service.status.0.load_balancer.0.ingress.0.hostname).0

  depends_on = [
    kubernetes_service.control_tower_service
  ]
}

resource "aws_api_gateway_vpc_link" "control_tower_lb_vpc_link" {
  name        = "Control Tower LB VPC link"
  description = "VPC link to the control-tower service load balancer"
  target_arns = [data.aws_lb.control_tower_lb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_resource" "control_tower_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.resource_root_id
  path_part   = "{proxy+}"
}


module "control_tower_any" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.control_tower_proxy_resource
  method       = "ANY"
  uri          = "http://api.resourcewatch.org/{proxy}"
  vpc_link     = aws_api_gateway_vpc_link.control_tower_lb_vpc_link
}
