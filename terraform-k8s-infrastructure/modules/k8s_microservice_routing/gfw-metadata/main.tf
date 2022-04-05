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

module "v1_gfw_metadata_proxy_endpoint" {
  source       = "../endpoint-proxy"
  api_gateway  = var.api_gateway
  backend_url  = "http://gis-gfw.wri.org/metadata/{proxy}"
  method       = "ANY"
  api_resource = module.v1_gfw_metadata_proxy_resource.aws_api_gateway_resource
}