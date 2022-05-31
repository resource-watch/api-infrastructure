// /v1/fw-alerts
module "v1_fw_alerts_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "fw-alerts"
}

// /v1/fw-alerts/{proxy+}
module "v1_fw_alerts_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_fw_alerts_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "fw_alerts_any_v1_form_proxy" {
  source       = "../endpoint-proxy"
  api_gateway  = var.api_gateway
  backend_url  = "${var.backend_url}/v1/fw-alerts/{proxy}"
  method       = "ANY"
  api_resource = module.v1_fw_alerts_proxy_resource.aws_api_gateway_resource
}