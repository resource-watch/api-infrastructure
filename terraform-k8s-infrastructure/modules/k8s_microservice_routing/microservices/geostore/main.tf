resource "kubernetes_service" "geostore_service" {
  metadata {
    name = "geostore"

  }
  spec {
    selector = {
      name = "geostore"
    }
    port {
      port        = 30532
      node_port   = 30532
      target_port = 3100
    }

    type = "NodePort"
  }
}

resource "aws_lb_listener" "geostore_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30532
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.geostore_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "geostore_lb_target_group" {
  name        = "geostore-lb-tg"
  port        = 30532
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_geostore" {
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.geostore_lb_target_group.arn
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
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_geostore_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30532/api/v1/geostore"
  vpc_link     = var.vpc_link
}

module "geostore_post_v1_geostore_find_by_ids" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_geostore_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30532/api/v1/geostore/find-by-ids"
  vpc_link     = var.vpc_link
}

module "geostore_post_v1_geostore_area" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_geostore_area_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30532/api/v1/geostore/area"
  vpc_link     = var.vpc_link
}

module "geostore_get_v1_geostore_id" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_geostore_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30532/api/v1/geostore/{geostoreId}"
  vpc_link     = var.vpc_link
}

module "geostore_get_v1_geostore_id_view" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.v1_geostore_id_view_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30532/api/v1/geostore/{geostoreId}/view"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["geostoreId"]
}

module "geostore_get_v1_geostore_admin_iso" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_geostore_admin_iso_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30532/api/v1/geostore/admin/{iso}"
  vpc_link     = var.vpc_link
}

module "geostore_get_v1_geostore_admin_list" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_geostore_admin_list_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30532/api/v1/geostore/admin/list"
  vpc_link     = var.vpc_link
}

module "geostore_get_v1_geostore_admin_iso_id1" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.v1_geostore_admin_iso_id1_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30532/api/v1/geostore/admin/{iso}/{id1}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["iso"]
}

module "geostore_get_v1_geostore_admin_iso_id1_id2" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.v1_geostore_admin_iso_id1_id2_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30532/api/v1/geostore/admin/{iso}/{id1}/{id2}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["iso", "id1"]
}

module "geostore_get_v1_geostore_use_name_id" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.v1_geostore_use_name_id_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30532/api/v1/geostore/use/{name}/{id}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["name"]
}

module "geostore_get_v1_geostore_wdpa_id" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_geostore_wdpa_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30532/api/v1/geostore/wdpa/{id}"
  vpc_link     = var.vpc_link
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
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.v1_coverage_intersect_use_name_id_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30532/api/v1/coverage/intersect/use/{name}/{id}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["name"]
}

module "geostore_get_v1_coverage_intersect_admin_iso" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_coverage_intersect_admin_iso_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30532/api/v1/coverage/intersect/admin/{iso}"
  vpc_link     = var.vpc_link
}

module "geostore_get_v1_coverage_intersect_admin_iso_id1" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.v1_coverage_intersect_admin_iso_id1_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30532/api/v1/coverage/intersect/admin/{iso}/{id1}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["iso"]
}

module "geostore_get_v1_coverage_intersect_wdpa_id" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_coverage_intersect_wdpa_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30532/api/v1/coverage/intersect/wdpa/{id}"
  vpc_link     = var.vpc_link
}

module "geostore_get_v1_coverage_intersect" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v1_coverage_intersect_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30532/api/v1/coverage/intersect"
  vpc_link     = var.vpc_link
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
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_geostore_find_by_ids_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30532/api/v2/geostore/find-by-ids"
  vpc_link     = var.vpc_link
}

module "geostore_post_v2_geostore_area" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_geostore_area_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30532/api/v2/geostore/area"
  vpc_link     = var.vpc_link
}

module "geostore_get_v2_geostore_id" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_geostore_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30532/api/v2/geostore/{geostoreId}"
  vpc_link     = var.vpc_link
}

module "geostore_get_v2_geostore_id_view" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.v2_geostore_id_view_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30532/api/v2/geostore/{geostoreId}/view"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["geostoreId"]
}

module "geostore_get_v2_geostore_admin_iso" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_geostore_admin_iso_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30532/api/v2/geostore/admin/{iso}"
  vpc_link     = var.vpc_link
}

module "geostore_get_v2_geostore_admin_list" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_geostore_admin_list_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30532/api/v2/geostore/admin/list"
  vpc_link     = var.vpc_link
}

module "geostore_get_v2_geostore_admin_iso_id1" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.v2_geostore_admin_iso_id1_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30532/api/v2/geostore/admin/{iso}/{id1}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["iso"]
}

module "geostore_get_v2_geostore_admin_iso_id1_id2" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.v2_geostore_admin_iso_id1_id2_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30532/api/v2/geostore/admin/{iso}/{id1}/{id2}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["iso", "id1"]
}

module "geostore_get_v2_geostore_use_name_id" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.v2_geostore_use_name_id_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30532/api/v2/geostore/use/{name}/{id}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["name"]
}

module "geostore_get_v2_geostore_wdpa_id" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_geostore_wdpa_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30532/api/v2/geostore/wdpa/{id}"
  vpc_link     = var.vpc_link
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
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.v2_coverage_intersect_use_name_id_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30532/api/v2/coverage/intersect/use/{name}/{id}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["name"]
}

module "geostore_get_v2_coverage_intersect_admin_iso" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_coverage_intersect_admin_iso_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30532/api/v2/coverage/intersect/admin/{iso}"
  vpc_link     = var.vpc_link
}

module "geostore_get_v2_coverage_intersect_admin_iso_id1" {
  source                      = "../../endpoint"
  api_gateway                 = var.api_gateway
  api_resource                = aws_api_gateway_resource.v2_coverage_intersect_admin_iso_id1_resource
  method                      = "GET"
  uri                         = "http://api.resourcewatch.org:30532/api/v2/coverage/intersect/admin/{iso}/{id1}"
  vpc_link                    = var.vpc_link
  endpoint_request_parameters = ["iso"]
}

module "geostore_get_v2_coverage_intersect_wdpa_id" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_coverage_intersect_wdpa_id_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30532/api/v2/coverage/intersect/wdpa/{id}"
  vpc_link     = var.vpc_link
}

module "geostore_get_v2_coverage_intersect" {
  source       = "../../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.v2_coverage_intersect_resource
  method       = "GET"
  uri          = "http://api.resourcewatch.org:30532/api/v2/coverage/intersect"
  vpc_link     = var.vpc_link
}