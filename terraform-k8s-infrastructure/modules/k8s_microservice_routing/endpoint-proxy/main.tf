resource "aws_api_gateway_method" "endpoint_proxy_method" {
  rest_api_id        = var.api_gateway.id
  resource_id        = var.api_resource.id
  http_method        = var.method
  request_parameters = { "method.request.path.proxy" = true }
  authorization      = var.authorization
  api_key_required   = var.require_api_key
  authorizer_id      = var.authorizer_id
}

resource "aws_api_gateway_integration" "endpoint_proxy_integration" {
  rest_api_id = var.api_gateway.id
  resource_id = var.api_resource.id
  http_method = var.method

  type                    = "HTTP_PROXY"
  uri                     = var.backend_url
  integration_http_method = var.method

  connection_type = "INTERNET"

  request_parameters = { "integration.request.path.proxy" = "method.request.path.proxy" }
}
