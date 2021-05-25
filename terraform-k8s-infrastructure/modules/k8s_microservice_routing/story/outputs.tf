output "endpoints" {
  value = [
    module.story_any_v1_story_proxy.endpoint_gateway_integration,
    module.story_get_v1_story.endpoint_gateway_integration,
    module.story_post_v1_story.endpoint_gateway_integration
  ]
}