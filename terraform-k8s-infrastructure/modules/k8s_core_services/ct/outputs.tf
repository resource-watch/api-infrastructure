output "endpoints" {
  value = [
    module.control_tower_v1_any.endpoint_gateway_integration,
    module.control_tower_v2_any.endpoint_gateway_integration,
    module.control_tower_v3_any.endpoint_gateway_integration,
  ]
}