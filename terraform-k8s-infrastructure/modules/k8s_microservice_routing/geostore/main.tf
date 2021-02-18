provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
    var.cluster_name]
    command = "aws"
  }
}

resource "kubernetes_service" "geostore_service" {
  metadata {
    name = "geostore"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                 = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=geostore"
    }
  }
  spec {
    selector = {
      name = "geostore"
    }
    port {
      port        = 80
      target_port = 3100
    }

    type = "LoadBalancer"
  }
}

data "aws_lb" "geostore_lb" {
  name = split("-", kubernetes_service.geostore_service.status.0.load_balancer.0.ingress.0.hostname).0

  depends_on = [
    kubernetes_service.geostore_service
  ]
}

resource "aws_api_gateway_vpc_link" "geostore_lb_vpc_link" {
  name        = "Geostore LB VPC link"
  description = "VPC link to the geostore service load balancer"
  target_arns = [
  data.aws_lb.geostore_lb.arn]

  lifecycle {
    create_before_destroy = true
  }
}

#
# V1 Geostore
#

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v2
data "aws_api_gateway_resource" "v2_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v2"
}

// /v1/geostore
resource "aws_api_gateway_resource" "v1_geostore_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "geostore"
}

// /v1/geostore/find-by-ids
resource "aws_api_gateway_resource" "v1_geostore_find_by_ids_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_geostore_resource.id
  path_part   = "find-by-ids"
}

// /v1/geostore/area
resource "aws_api_gateway_resource" "v1_geostore_area_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_geostore_resource.id
  path_part   = "area"
}

// /v1/geostore/{geostoreId}
resource "aws_api_gateway_resource" "v1_geostore_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_geostore_resource.id
  path_part   = "{geostoreId}"
}

// /v1/geostore/{geostoreId}/view
resource "aws_api_gateway_resource" "v1_geostore_id_view_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_geostore_id_resource.id
  path_part   = "view"
}

// /v1/geostore/admin
resource "aws_api_gateway_resource" "v1_geostore_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_geostore_resource.id
  path_part   = "admin"
}

// /v1/geostore/admin/{iso}
resource "aws_api_gateway_resource" "v1_geostore_admin_iso_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_geostore_admin_resource.id
  path_part   = "{iso}"
}

// /v1/geostore/admin/list
resource "aws_api_gateway_resource" "v1_geostore_admin_list_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_geostore_admin_resource.id
  path_part   = "list"
}

// /v1/geostore/admin/{iso}/{id1}
resource "aws_api_gateway_resource" "v1_geostore_admin_iso_id1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_geostore_admin_iso_resource.id
  path_part   = "{id1}"
}

// /v1/geostore/admin/{iso}/{id1}/{id2}
resource "aws_api_gateway_resource" "v1_geostore_admin_iso_id1_id2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_geostore_admin_iso_id1_resource.id
  path_part   = "{id2}"
}

// /v1/geostore/use
resource "aws_api_gateway_resource" "v1_geostore_use_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_geostore_resource.id
  path_part   = "use"
}

// /v1/geostore/use/{name}
resource "aws_api_gateway_resource" "v1_geostore_use_name_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_geostore_use_resource.id
  path_part   = "{name}"
}

// /v1/geostore/use/{name}/{id}
resource "aws_api_gateway_resource" "v1_geostore_use_name_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_geostore_use_name_resource.id
  path_part   = "{id}"
}

// /v1/geostore/wdpa
resource "aws_api_gateway_resource" "v1_geostore_wdpa_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_geostore_resource.id
  path_part   = "wdpa"
}

// /v1/geostore/wdpa/{id}
resource "aws_api_gateway_resource" "v1_geostore_wdpa_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_geostore_wdpa_resource.id
  path_part   = "{id}"
}

module "geostore_post_v1_geostore" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_geostore_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/geostore"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_post_v1_geostore_find_by_ids" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_geostore_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/geostore/find-by-ids"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_post_v1_geostore_area" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_geostore_area_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v1/geostore/area"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_get_v1_geostore_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_geostore_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/geostore/{geostoreId}"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_get_v1_geostore_id_view" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_geostore_id_view_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/geostore/{geostoreId}/view"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_get_v1_geostore_admin_iso" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_geostore_admin_iso_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/geostore/admin/{iso}"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_get_v1_geostore_admin_list" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_geostore_admin_list_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/geostore/admin/list"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_get_v1_geostore_admin_iso_id1" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_geostore_admin_iso_id1_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/geostore/admin/{iso}/{id1}"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_get_v1_geostore_admin_iso_id1_id2" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_geostore_admin_iso_id1_id2_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/geostore/admin/{iso}/{id1}/{id2}"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_get_v1_geostore_use_name_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_geostore_use_name_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/geostore/use/{name}/{id}"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_get_v1_geostore_wdpa_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_geostore_wdpa_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/geostore/wdpa/{id}"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

#
# V1 Coverage
#

// /v1/coverage
resource "aws_api_gateway_resource" "v1_coverage_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "coverage"
}

// /v1/coverage/intersect
resource "aws_api_gateway_resource" "v1_coverage_intersect_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_coverage_resource.id
  path_part   = "intersect"
}

// /v1/coverage/intersect/use
resource "aws_api_gateway_resource" "v1_coverage_intersect_use_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_coverage_intersect_resource.id
  path_part   = "use"
}

// /v1/coverage/intersect/use/{name}
resource "aws_api_gateway_resource" "v1_coverage_intersect_use_name_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_coverage_intersect_use_resource.id
  path_part   = "{name}"
}

// /v1/coverage/intersect/use/{name}/{id}
resource "aws_api_gateway_resource" "v1_coverage_intersect_use_name_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_coverage_intersect_use_name_resource.id
  path_part   = "{id}"
}

// /v1/coverage/intersect/admin
resource "aws_api_gateway_resource" "v1_coverage_intersect_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_coverage_intersect_resource.id
  path_part   = "admin"
}

// /v1/coverage/intersect/admin/{iso}
resource "aws_api_gateway_resource" "v1_coverage_intersect_admin_iso_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_coverage_intersect_admin_resource.id
  path_part   = "{iso}"
}

// /v1/coverage/intersect/admin/{iso}/{id1}
resource "aws_api_gateway_resource" "v1_coverage_intersect_admin_iso_id1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_coverage_intersect_admin_iso_resource.id
  path_part   = "{id1}"
}

// /v1/coverage/intersect/wdpa
resource "aws_api_gateway_resource" "v1_coverage_intersect_wdpa_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_coverage_intersect_resource.id
  path_part   = "wdpa"
}

// /v1/coverage/intersect/wdpa/{id}
resource "aws_api_gateway_resource" "v1_coverage_intersect_wdpa_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v1_coverage_intersect_wdpa_resource.id
  path_part   = "{id}"
}

module "geostore_get_v1_coverage_intersect_use_name_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_coverage_intersect_use_name_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/coverage/intersect/use/{name}/{id}"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_get_v1_coverage_intersect_admin_iso" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_coverage_intersect_admin_iso_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/coverage/intersect/admin/{iso}"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_get_v1_coverage_intersect_admin_iso_id1" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_coverage_intersect_admin_iso_id1_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/coverage/intersect/admin/{iso}/{id1}"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_get_v1_coverage_intersect_wdpa_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_coverage_intersect_wdpa_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/coverage/intersect/wdpa/{id}"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_get_v1_coverage_intersect" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_coverage_intersect_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v1/coverage/intersect"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

#
# V2 Geostore
#

// /v2/geostore
resource "aws_api_gateway_resource" "v2_geostore_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v2_resource.id
  path_part   = "geostore"
}

// /v2/geostore/find-by-ids
resource "aws_api_gateway_resource" "v2_geostore_find_by_ids_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_geostore_resource.id
  path_part   = "find-by-ids"
}

// /v2/geostore/area
resource "aws_api_gateway_resource" "v2_geostore_area_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_geostore_resource.id
  path_part   = "area"
}

// /v2/geostore/{geostoreId}
resource "aws_api_gateway_resource" "v2_geostore_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_geostore_resource.id
  path_part   = "{geostoreId}"
}

// /v2/geostore/{geostoreId}/view
resource "aws_api_gateway_resource" "v2_geostore_id_view_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_geostore_id_resource.id
  path_part   = "view"
}

// /v2/geostore/admin
resource "aws_api_gateway_resource" "v2_geostore_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_geostore_resource.id
  path_part   = "admin"
}

// /v2/geostore/admin/{iso}
resource "aws_api_gateway_resource" "v2_geostore_admin_iso_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_geostore_admin_resource.id
  path_part   = "{iso}"
}

// /v2/geostore/admin/list
resource "aws_api_gateway_resource" "v2_geostore_admin_list_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_geostore_admin_resource.id
  path_part   = "list"
}

// /v2/geostore/admin/{iso}/{id1}
resource "aws_api_gateway_resource" "v2_geostore_admin_iso_id1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_geostore_admin_iso_resource.id
  path_part   = "{id1}"
}

// /v2/geostore/admin/{iso}/{id1}/{id2}
resource "aws_api_gateway_resource" "v2_geostore_admin_iso_id1_id2_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_geostore_admin_iso_id1_resource.id
  path_part   = "{id2}"
}

// /v2/geostore/use
resource "aws_api_gateway_resource" "v2_geostore_use_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_geostore_resource.id
  path_part   = "use"
}

// /v2/geostore/use/{name}
resource "aws_api_gateway_resource" "v2_geostore_use_name_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_geostore_use_resource.id
  path_part   = "{name}"
}

// /v2/geostore/use/{name}/{id}
resource "aws_api_gateway_resource" "v2_geostore_use_name_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_geostore_use_name_resource.id
  path_part   = "{id}"
}

// /v2/geostore/wdpa
resource "aws_api_gateway_resource" "v2_geostore_wdpa_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_geostore_resource.id
  path_part   = "wdpa"
}

// /v2/geostore/wdpa/{id}
resource "aws_api_gateway_resource" "v2_geostore_wdpa_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_geostore_wdpa_resource.id
  path_part   = "{id}"
}

module "geostore_post_v2_geostore_find_by_ids" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_geostore_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v2/geostore/find-by-ids"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_post_v2_geostore_area" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_geostore_area_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org/api/v2/geostore/area"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_get_v2_geostore_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_geostore_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/geostore/{geostoreId}"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_get_v2_geostore_id_view" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_geostore_id_view_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/geostore/{geostoreId}/view"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_get_v2_geostore_admin_iso" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_geostore_admin_iso_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/geostore/admin/{iso}"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_get_v2_geostore_admin_list" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_geostore_admin_list_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/geostore/admin/list"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_get_v2_geostore_admin_iso_id1" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_geostore_admin_iso_id1_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/geostore/admin/{iso}/{id1}"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_get_v2_geostore_admin_iso_id1_id2" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_geostore_admin_iso_id1_id2_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/geostore/admin/{iso}/{id1}/{id2}"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_get_v2_geostore_use_name_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_geostore_use_name_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/geostore/use/{name}/{id}"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_get_v2_geostore_wdpa_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_geostore_wdpa_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/geostore/wdpa/{id}"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

#
# V2 Coverage
#

// /v2/coverage
resource "aws_api_gateway_resource" "v2_coverage_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v2_resource.id
  path_part   = "coverage"
}

// /v2/coverage/intersect
resource "aws_api_gateway_resource" "v2_coverage_intersect_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_coverage_resource.id
  path_part   = "intersect"
}

// /v2/coverage/intersect/use
resource "aws_api_gateway_resource" "v2_coverage_intersect_use_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_coverage_intersect_resource.id
  path_part   = "use"
}

// /v2/coverage/intersect/use/{name}
resource "aws_api_gateway_resource" "v2_coverage_intersect_use_name_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_coverage_intersect_use_resource.id
  path_part   = "{name}"
}

// /v2/coverage/intersect/use/{name}/{id}
resource "aws_api_gateway_resource" "v2_coverage_intersect_use_name_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_coverage_intersect_use_name_resource.id
  path_part   = "{id}"
}

// /v2/coverage/intersect/admin
resource "aws_api_gateway_resource" "v2_coverage_intersect_admin_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_coverage_intersect_resource.id
  path_part   = "admin"
}

// /v2/coverage/intersect/admin/{iso}
resource "aws_api_gateway_resource" "v2_coverage_intersect_admin_iso_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_coverage_intersect_admin_resource.id
  path_part   = "{iso}"
}

// /v2/coverage/intersect/admin/{iso}/{id1}
resource "aws_api_gateway_resource" "v2_coverage_intersect_admin_iso_id1_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_coverage_intersect_admin_iso_resource.id
  path_part   = "{id1}"
}

// /v2/coverage/intersect/wdpa
resource "aws_api_gateway_resource" "v2_coverage_intersect_wdpa_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_coverage_intersect_resource.id
  path_part   = "wdpa"
}

// /v2/coverage/intersect/wdpa/{id}
resource "aws_api_gateway_resource" "v2_coverage_intersect_wdpa_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.v2_coverage_intersect_wdpa_resource.id
  path_part   = "{id}"
}

module "geostore_get_v2_coverage_intersect_use_name_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_coverage_intersect_use_name_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/coverage/intersect/use/{name}/{id}"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_get_v2_coverage_intersect_admin_iso" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_coverage_intersect_admin_iso_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/coverage/intersect/admin/{iso}"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_get_v2_coverage_intersect_admin_iso_id1" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_coverage_intersect_admin_iso_id1_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/coverage/intersect/admin/{iso}/{id1}"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_get_v2_coverage_intersect_wdpa_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_coverage_intersect_wdpa_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/coverage/intersect/wdpa/{id}"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}

module "geostore_get_v2_coverage_intersect" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_coverage_intersect_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org/api/v2/coverage/intersect"
  vpc_link     = aws_api_gateway_vpc_link.geostore_lb_vpc_link
}