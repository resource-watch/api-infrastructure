// /v1/contextual-layer
module "v1_contextual_layer_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "contextual-layer"
}

// /v1/contextual-layer/{proxy+}
module "v1_contextual_layer_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_contextual_layer_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "fw_contextual_layers_get_v1_contextual_layer" {
  source       = "../../endpoint-proxy"
  api_gateway  = var.api_gateway
  backend_url  = "${var.backend_url}/v1/contextual-layer"
  method       = "GET"
  api_resource = module.v1_contextual_layer_resource.aws_api_gateway_resource
}

module "fw_contextual_layers_post_v1_contextual_layer" {
  source       = "../../endpoint-proxy"
  api_gateway  = var.api_gateway
  backend_url  = "${var.backend_url}/v1/contextual-layer"
  method       = "POST"
  api_resource = module.v1_contextual_layer_resource.aws_api_gateway_resource
}

module "fw_contextual_layers_any_v1_contextual_layer_proxy" {
  source       = "../../endpoint-proxy"
  api_gateway  = var.api_gateway
  backend_url  = "${var.backend_url}/v1/contextual-layer/{proxy}"
  method       = "ANY"
  api_resource = module.v1_contextual_layer_proxy_resource.aws_api_gateway_resource
}