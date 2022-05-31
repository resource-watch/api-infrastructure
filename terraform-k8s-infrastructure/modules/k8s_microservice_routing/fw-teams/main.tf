// /v1/teams
module "v1_teams_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "teams"
}

// /v1/teams/{proxy+}
module "v1_teams_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_teams_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "fw_teams_post_v1_teams" {
  source       = "../endpoint-proxy"
  api_gateway  = var.api_gateway
  backend_url  = "${var.backend_url}/v1/teams"
  method       = "POST"
  api_resource = module.v1_teams_resource.aws_api_gateway_resource
}

module "fw_teams_any_v1_teams_proxy" {
  source       = "../endpoint-proxy"
  api_gateway  = var.api_gateway
  backend_url  = "${var.backend_url}/v1/teams/{proxy}"
  method       = "ANY"
  api_resource = module.v1_teams_proxy_resource.aws_api_gateway_resource
}
