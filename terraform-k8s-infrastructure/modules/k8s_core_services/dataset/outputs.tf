output "dateset_endpoints" {
  value = [
    module.dateset_get.endpoint_gateway_integration,
    module.dateset_get_proxy.endpoint_gateway_integration,
    module.dateset_patch_proxy.endpoint_gateway_integration,
    module.dateset_post.endpoint_gateway_integration,
    module.dateset_post_find_by_id.endpoint_gateway_integration,
    module.dateset_post_upload.endpoint_gateway_integration,
    module.dateset_delete_proxy.endpoint_gateway_integration,
  ]
}