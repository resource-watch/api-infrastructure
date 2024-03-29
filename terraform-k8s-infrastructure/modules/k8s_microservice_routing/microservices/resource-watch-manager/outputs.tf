output "endpoints" {
  value = [
    module.resource_watch_manager_get_v1_dashboard.endpoint_gateway_integration,
    module.resource_watch_manager_post_v1_dashboard.endpoint_gateway_integration,
    module.resource_watch_manager_any_v1_dashboard_proxy.endpoint_gateway_integration,
    module.resource_watch_manager_get_v1_partner.endpoint_gateway_integration,
    module.resource_watch_manager_post_v1_partner.endpoint_gateway_integration,
    module.resource_watch_manager_get_v1_partner_id.endpoint_gateway_integration,
    module.resource_watch_manager_patch_v1_partner_id.endpoint_gateway_integration,
    module.resource_watch_manager_put_v1_partner_id.endpoint_gateway_integration,
    module.resource_watch_manager_delete_v1_partner_id.endpoint_gateway_integration,
    module.resource_watch_manager_get_v1_static_page.endpoint_gateway_integration,
    module.resource_watch_manager_post_v1_static_page.endpoint_gateway_integration,
    module.resource_watch_manager_get_v1_static_page_id.endpoint_gateway_integration,
    module.resource_watch_manager_patch_v1_static_page_id.endpoint_gateway_integration,
    module.resource_watch_manager_put_v1_static_page_id.endpoint_gateway_integration,
    module.resource_watch_manager_delete_v1_static_page_id.endpoint_gateway_integration,
    module.resource_watch_manager_any_v1_topic_proxy,
    module.resource_watch_manager_post_v1_topic.endpoint_gateway_integration,
    module.resource_watch_manager_get_v1_tool.endpoint_gateway_integration,
    module.resource_watch_manager_post_v1_tool.endpoint_gateway_integration,
    module.resource_watch_manager_get_v1_tool_id.endpoint_gateway_integration,
    module.resource_watch_manager_patch_v1_tool_id.endpoint_gateway_integration,
    module.resource_watch_manager_put_v1_tool_id.endpoint_gateway_integration,
    module.resource_watch_manager_delete_v1_tool_id.endpoint_gateway_integration,
    module.resource_watch_manager_post_v1_profile.endpoint_gateway_integration,
    module.resource_watch_manager_get_v1_profile_id.endpoint_gateway_integration,
    module.resource_watch_manager_patch_v1_profile_id.endpoint_gateway_integration,
    module.resource_watch_manager_put_v1_profile_id.endpoint_gateway_integration,
    module.resource_watch_manager_delete_v1_profile_id.endpoint_gateway_integration,
    module.resource_watch_manager_get_v1_faq.endpoint_gateway_integration,
    module.resource_watch_manager_post_v1_faq.endpoint_gateway_integration,
    module.resource_watch_manager_any_v1_faq_proxy.endpoint_gateway_integration,
    module.resource_watch_manager_post_v1_temporary_content_image.endpoint_gateway_integration,
    module.resource_watch_manager_post_v1_contact_us.endpoint_gateway_integration,
  ]
}
