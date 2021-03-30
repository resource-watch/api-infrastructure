output "endpoints" {
  value = [
    module.graph_client_any_graph_proxy.endpoint_gateway_integration
  ]
}