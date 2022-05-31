// /v1/questionnaire
module "v1_questionnaire_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "questionnaire"
}

// /v1/questionnaire/{proxy+}
module "v1_questionnaire_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_questionnaire_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

// /v1/reports
module "v1_reports_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "reports"
}

// /v1/reports/{proxy+}
module "v1_reports_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_reports_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "forms_any_v1_questionnaire" {
  source       = "../endpoint-proxy"
  api_gateway  = var.api_gateway
  backend_url  = "${var.backend_url}/v1/questionnaire"
  method       = "ANY"
  api_resource = module.v1_questionnaire_resource.aws_api_gateway_resource
}

module "forms_any_v1_questionnaire_proxy" {
  source       = "../endpoint-proxy"
  api_gateway  = var.api_gateway
  backend_url  = "${var.backend_url}/v1/questionnaire/{proxy}"
  method       = "ANY"
  api_resource = module.v1_questionnaire_proxy_resource.aws_api_gateway_resource
}

module "forms_any_v1_reports" {
  source       = "../endpoint-proxy"
  api_gateway  = var.api_gateway
  backend_url  = "${var.backend_url}/v1/reports"
  method       = "ANY"
  api_resource = module.v1_reports_resource.aws_api_gateway_resource
}

module "forms_any_v1_reports_proxy" {
  source       = "../endpoint-proxy"
  api_gateway  = var.api_gateway
  backend_url  = "${var.backend_url}/v1/reports/{proxy}"
  method       = "ANY"
  api_resource = module.v1_reports_proxy_resource.aws_api_gateway_resource
}