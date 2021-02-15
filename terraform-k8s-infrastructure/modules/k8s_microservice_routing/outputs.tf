output "api_url" {
  value = cloudflare_record.env_api_resourcewatch_org_dns.name
}

output "stage_name" {
  value = aws_api_gateway_deployment.prod.stage_name
}