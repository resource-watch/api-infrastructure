resource "aws_api_gateway_method" "endpoint_proxy_method" {
  rest_api_id        = var.api_gateway.id
  resource_id        = var.api_resource.id
  http_method        = var.method
  authorization      = "NONE"
  request_parameters = { "method.request.path.proxy" = true }
}

resource "aws_api_gateway_integration" "endpoint_proxy_integration" {
  rest_api_id = var.api_gateway.id
  resource_id = var.api_resource.id
  http_method = var.method
  type                    = "MOCK"

  request_templates = {
    "application/json" : "{\"statusCode\": 503}"
  }
}

resource "aws_api_gateway_method_response" "endpoint_method_response" {
  rest_api_id = var.api_gateway.id
  resource_id = var.api_resource.id
  http_method = var.method
  status_code = 503
}

resource "aws_api_gateway_integration_response" "get_v1_endpoint_integration_response" {
  rest_api_id = var.api_gateway.id
  resource_id = var.api_resource.id
  http_method = var.method
  status_code = aws_api_gateway_method_response.endpoint_method_response.status_code

  # Transforms the backend JSON response to XML
  response_templates = {
    "application/json" = <<EOF
#set($inputRoot = $input.path('$'))
{"message":"Temporarily under maintenance" }
EOF
  }
}