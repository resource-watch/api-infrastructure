resource "aws_api_gateway_method" "endpoint_method" {
  rest_api_id   = var.api_gateway.id
  resource_id   = var.api_resource.id
  http_method   = var.method
  authorization = "NONE"
  request_parameters = merge(
    (length(regexall("\\{(.*)\\}", var.api_resource.path_part)) > 0 ? { "method.request.path.${replace(var.api_resource.path_part, "/\\{|\\}|\\+/", "")}" = true } : {}),
    { for s in var.endpoint_request_parameters : "method.request.path.${s}" => true }
  )
}

resource "aws_api_gateway_integration" "endpoint_integration" {
  rest_api_id = var.api_gateway.id
  resource_id = var.api_resource.id
  http_method = aws_api_gateway_method.endpoint_method.http_method

  type                    = "HTTP_PROXY"
  uri                     = var.uri
  integration_http_method = var.method

  connection_type = "VPC_LINK"
  connection_id   = var.vpc_link.id

  request_parameters = merge(
    (length(regexall("\\{(.*)\\}", var.api_resource.path_part)) > 0 ? { "integration.request.path.${replace(var.api_resource.path_part, "/\\{|\\}|\\+/", "")}" = "method.request.path.${replace(var.api_resource.path_part, "/\\{|\\}|\\+/", "")}" } : {}),
    { for s in var.endpoint_request_parameters : "integration.request.path.${s}" => "method.request.path.${s}" }
  )
}