provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

resource "kubernetes_service" "biomass_service" {
  metadata {
    name = "biomass"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                 = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=biomass"
    }
  }
  spec {
    selector = {
      name = "biomass"
    }
    port {
      port        = 80
      target_port = 3600
    }

    type = "LoadBalancer"
  }
}

data "aws_lb" "biomass_lb" {
  name = split("-", kubernetes_service.biomass_service.status.0.load_balancer.0.ingress.0.hostname).0

  depends_on = [
    kubernetes_service.biomass_service
  ]
}

resource "aws_api_gateway_vpc_link" "biomass_lb_vpc_link" {
  name        = "Biomass loss LB VPC link"
  description = "VPC link to the biomass loss service load balancer"
  target_arns = [data.aws_lb.biomass_lb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v1/biomass-loss
resource "aws_api_gateway_resource" "biomass_loss_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "biomass-loss"
}

// /v1/biomass-loss/admin
resource "aws_api_gateway_resource" "biomass_loss_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.biomass_loss_resource.id
  path_part   = "admin"
}

// /v1/biomass-loss/admin/{iso}
resource "aws_api_gateway_resource" "biomass_loss_admin_iso_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.biomass_loss_admin_resource.id
  path_part   = "{iso}"
}

// /v1/biomass-loss/admin/{iso}/{id}
resource "aws_api_gateway_resource" "biomass_loss_admin_iso_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.biomass_loss_admin_iso_resource.id
  path_part   = "{id}"
}


# Modules
module "biomass_v1_get_biomass_loss_admin_iso" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.biomass_loss_admin_iso_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/biomass-loss/admin/{iso}"
  vpc_link     = aws_api_gateway_vpc_link.biomass_lb_vpc_link
}

module "biomass_v1_get_biomass_loss_admin_iso_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.biomass_loss_admin_iso_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/biomass-loss/admin/{iso}/{id}"
  vpc_link     = aws_api_gateway_vpc_link.biomass_lb_vpc_link
}
