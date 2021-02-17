provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

resource "kubernetes_service" "rw_lp_service" {
  metadata {
    name      = "rw-lp"
    namespace = "default"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                 = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=rw-lp"
    }
  }
  spec {
    selector = {
      name = "rw-lp"
    }
    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}

data "aws_lb" "rw_lp_lb" {
  name = split("-", kubernetes_service.rw_lp_service.status.0.load_balancer.0.ingress.0.hostname).0

  depends_on = [
    kubernetes_service.rw_lp_service
  ]
}

resource "aws_api_gateway_vpc_link" "rw_lp_lb_vpc_link" {
  name        = "RW API landing page LB VPC link"
  description = "VPC link to the rw-lp service load balancer"
  target_arns = [data.aws_lb.rw_lp_lb.arn]

  lifecycle {
    create_before_destroy = true
  }
}
// /
data "aws_api_gateway_resource" "root_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/"
}

// /rw-lp
resource "aws_api_gateway_resource" "rw_lp_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.root_resource.id
  path_part   = "rw-lp"
}

// /rw-lp/{proxy+}
resource "aws_api_gateway_resource" "rw_lp_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.rw_lp_resource.id
  path_part   = "{proxy+}"
}

module "rw_lp_get_home" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = data.aws_api_gateway_resource.root_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/"
  vpc_link     = aws_api_gateway_vpc_link.rw_lp_lb_vpc_link
}

module "rw_lp_get_rw_lp_proxy" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.rw_lp_proxy_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/rw-lp/{proxy}"
  vpc_link     = aws_api_gateway_vpc_link.rw_lp_lb_vpc_link
}

