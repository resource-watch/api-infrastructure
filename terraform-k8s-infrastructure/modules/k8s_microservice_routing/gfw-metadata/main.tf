#
# /v1/gfw-metadata/(.*)$ proxies to http://gis-gfw.wri.org/metadata/$1
#

// /v1/gfw-metadata
module "v1_gfw_metadata_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "gfw-metadata"
}

// /v1/gfw-metadata/{proxy+}
module "v1_gfw_metadata_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.v1_gfw_metadata_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "v1_gfw_metadata_proxy_method" {
  rest_api_id        = var.api_gateway.id
  resource_id        = module.v1_gfw_metadata_proxy_resource.aws_api_gateway_resource.id
  http_method        = "ANY"
  authorization      = "NONE"
  request_parameters = { "method.request.path.proxy" = true }
}

resource "aws_api_gateway_integration" "gfw_metadata_proxy_integration" {
  rest_api_id = var.api_gateway.id
  resource_id = module.v1_gfw_metadata_proxy_resource.aws_api_gateway_resource.id
  http_method = aws_api_gateway_method.v1_gfw_metadata_proxy_method.http_method

  type                    = "HTTP_PROXY"
  uri                     = "http://gis-gfw.wri.org/metadata/{proxy}"
  integration_http_method = "ANY"

  connection_type = "INTERNET"

  request_parameters = { "integration.request.path.proxy" = "method.request.path.proxy" }
}
