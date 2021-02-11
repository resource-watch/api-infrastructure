provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

resource "kubernetes_service" "dataset_service" {{
  metadata {
    name      = "viirs-fires"
    namespace = "gfw"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                 = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=dataset"
    }
  }
  spec {
    selector = {
      name = "viirs-fires"
    }
    port {
      port        = 80
      target_port = 3600
    }

    type = "LoadBalancer"
  }
}

data "aws_lb" "viirs_fires_lb" {
  name = split("-", kubernetes_service.dataset_service.status.0.load_balancer.0.ingress.0.hostname).0

  depends_on = [
    kubernetes_service.dataset_service
  ]
}

resource "aws_api_gateway_vpc_link" "viirs_fires_lb_vpc_link" {
  name        = "Dataset LB VPC link"
  description = "VPC link to the viirs fires service load balancer"
  target_arns = [data.aws_lb.dataset_lb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_resource" "viirs_fires_v2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.resource_root_v2_id
  path_part   = "viirs-active-fires"
}

resource "aws_api_gateway_resource" "viirs_latest_v2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_v2_resource.id
  path_part   = "latest"
}

# Access by GADM levels
resource "aws_api_gateway_resource" "viirs_fires_admin_v2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_v2_resource.id
  path_part   = "admin"
}

resource "aws_api_gateway_resource" "viirs_fires_by_iso_v2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_admin_v2_resource.id
  path_part   = "{iso}"
}

resource "aws_api_gateway_resource" "viirs_fires_by_id1_v2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_by_iso_v2_resource.id
  path_part   = "{id1}"
}

resource "aws_api_gateway_resource" "viirs_fires_by_id2_v2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_by_id1_v2_resource.id
  path_part   = "{id2}"
}

# Access by area id
resource "aws_api_gateway_resource" "viirs_fires_use_v2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_v2_resource.id
  path_part   = "use"
}

resource "aws_api_gateway_resource" "viirs_fires_use_by_name_v2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_use_v2_resource.id
  path_part   = "{name}"
}

resource "aws_api_gateway_resource" "viirs_fires_use_by_id_v2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_use_by_name_v2_resource.id
  path_part   = "{id}"
}

# Access Protected Areas by id
resource "aws_api_gateway_resource" "viirs_fires_wdpa_v2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_v2_resource.id
  path_part   = "wdpa"
}

resource "aws_api_gateway_resource" "viirs_fires_wdpa_by_id_v2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_wdpa_v2_resource.id
  path_part   = "{id}"
}

# v1 resources
resource "aws_api_gateway_resource" "viirs_fires_v1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = var.resource_root_v1_id
  path_part   = "viirs-active-fires"
}

resource "aws_api_gateway_resource" "viirs_latest_v1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_v1_resource.id
  path_part   = "latest"
}

# Access by GADM levels
resource "aws_api_gateway_resource" "viirs_fires_admin_v1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_v1_resource.id
  path_part   = "admin"
}

resource "aws_api_gateway_resource" "viirs_fires_by_iso_v1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_admin_v1_resource.id
  path_part   = "{iso}"
}

resource "aws_api_gateway_resource" "viirs_fires_by_id1_v1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_by_iso_v1_resource.id
  path_part   = "{id1}"
}

resource "aws_api_gateway_resource" "viirs_fires_by_id2_v1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_by_id1_v1_resource.id
  path_part   = "{id2}"
}

# Access by area id
resource "aws_api_gateway_resource" "viirs_fires_use_v1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_v1_resource.id
  path_part   = "use"
}

resource "aws_api_gateway_resource" "viirs_fires_use_by_name_v1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_use_v1_resource.id
  path_part   = "{name}"
}

resource "aws_api_gateway_resource" "viirs_fires_use_by_id_v1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_use_by_name_v1_resource.id
  path_part   = "{id}"
}

# Access Protected Areas by id
resource "aws_api_gateway_resource" "viirs_fires_wdpa_v1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_v1_resource.id
  path_part   = "wdpa"
}

resource "aws_api_gateway_resource" "viirs_fires_wdpa_by_id_v1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.viirs_fires_wdpa_v1_resource.id
  path_part   = "{id}"
}



module "dataset_flush" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_flush_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{id}/flush"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}

module "dataset_recover" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_recover_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{id}/recover"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}

module "dataset_last_updated" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_last_updated_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/{id}/lastUpdated"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}

module "dataset_post" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}

module "dataset_post_find_by_ids" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/find-by-ids"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}

module "dataset_post_upload" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_upload_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/upload"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}




module "active_fires_by_iso" {
// "/v2/viirs-active-fires/admin/:iso",
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_upload_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/dataset/upload"
  vpc_link     = aws_api_gateway_vpc_link.dataset_lb_vpc_link
}
