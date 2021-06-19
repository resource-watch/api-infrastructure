output "endpoints" {
  value = [
    module.forest_watcher_api_get_v1_forest_watcher_area_resource.endpoint_gateway_integration,
    module.forest_watcher_api_post_v1_forest_watcher_area_resource.endpoint_gateway_integration,
  ]
}