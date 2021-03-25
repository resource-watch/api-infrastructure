output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.ingress_load_balancer.domain_name
}