// /v1/forest-watcher
module "v1_forest_watcher_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "forest-watcher"
}

// /v1/forest-watcher/area
module "v1_forest_watcher_area_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_forest_watcher_resource.aws_api_gateway_resource.id
  path_part   = "area"
}

module "forest_watcher_api_get_v1_forest_watcher_area_resource" {
  source       = "../endpoint-proxy"
  api_gateway  = var.api_gateway
  backend_url  = "${var.backend_url}/v1/forest-watcher/area"
  method       = "GET"
  api_resource = module.v1_forest_watcher_area_resource.aws_api_gateway_resource
}

module "forest_watcher_api_post_v1_forest_watcher_area_resource" {
  source       = "../endpoint-proxy"
  api_gateway  = var.api_gateway
  backend_url  = "${var.backend_url}/v1/forest-watcher/area"
  method       = "POST"
  api_resource = module.v1_forest_watcher_area_resource.aws_api_gateway_resource
}
