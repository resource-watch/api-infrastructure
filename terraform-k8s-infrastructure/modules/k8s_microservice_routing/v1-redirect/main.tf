#
# /v1/(.*)$ redirects to ${var.target_domain}/v1/$1
#

// /
data "aws_api_gateway_resource" "root_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/"
}

// //{proxy+}
resource "aws_api_gateway_resource" "v1_redirect_proxy_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.root_resource.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "v1_redirect_proxy_method" {
  rest_api_id        = var.api_gateway.id
  resource_id        = aws_api_gateway_resource.v1_redirect_proxy_resource.id
  http_method        = "ANY"
  authorization      = "NONE"
  request_parameters = { "method.request.path.proxy" = true }
}

resource "aws_api_gateway_integration" "v1_redirect_proxy_integration" {
  rest_api_id = var.api_gateway.id
  resource_id = aws_api_gateway_resource.v1_redirect_proxy_resource.id
  http_method = aws_api_gateway_method.v1_redirect_proxy_method.http_method

  type                    = "HTTP_PROXY"
  uri                     = "https://${var.target_domain}/v1/{proxy}"
  integration_http_method = "ANY"

  connection_type = "INTERNET"

  request_parameters = { "integration.request.path.proxy" = "method.request.path.proxy" }
}
