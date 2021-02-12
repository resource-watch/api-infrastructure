output "api_url" {
  value = cloudflare_record.api_dns.name
}

output "stage_name" {
  value = aws_api_gateway_deployment.prod.stage_name
}