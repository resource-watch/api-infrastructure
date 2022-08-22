resource "aws_api_gateway_method" "endpoint_method" {
  rest_api_id        = var.api_gateway.id
  resource_id        = var.api_resource.id
  http_method        = var.method
  request_parameters = merge(
    (length(regexall("\\{(.*)\\}", var.api_resource.path_part)) > 0 ? {
      "method.request.path.${replace(var.api_resource.path_part, "/\\{|\\}|\\+/", "")}" = true
    } : {}),
    {for s in var.endpoint_request_parameters : "method.request.path.${s}" => true},
    { "method.request.header.Accept" : false }
  )
  authorization    = var.authorization
  api_key_required = var.require_api_key
  authorizer_id    = var.authorizer_id
}

resource "aws_api_gateway_integration" "endpoint_integration" {
  rest_api_id = var.api_gateway.id
  resource_id = var.api_resource.id
  http_method = aws_api_gateway_method.endpoint_method.http_method

  type                    = "HTTP_PROXY"
  uri                     = var.uri
  integration_http_method = var.method

  connection_type = var.connection_type
  connection_id   = var.vpc_link.id

  request_parameters = merge(
    {
      "integration.request.header.x-rw-domain" = "'${var.x_rw_domain}'"
      "integration.request.header.Accept"      = "method.request.header.Accept"
    },
    (length(regexall("\\{(.*)\\}", var.api_resource.path_part)) > 0 ? {
      "integration.request.path.${replace(var.api_resource.path_part, "/\\{|\\}|\\+/", "")}" = "method.request.path.${replace(var.api_resource.path_part, "/\\{|\\}|\\+/", "")}"
    } : {}),
    {for s in var.endpoint_request_parameters : "integration.request.path.${s}" => "method.request.path.${s}"}
  )
}