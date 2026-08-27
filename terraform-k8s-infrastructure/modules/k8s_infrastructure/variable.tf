variable "cluster_endpoint" {
  type        = string
  description = "The k8s cluster endpoint. Must be accessible from localhost"
}

variable "cluster_ca" {
  type        = string
  description = "The k8s CA string"
}

variable "cluster_name" {
  type        = string
  description = "The k8s cluster name"
}

variable "vpc_id" {
  type        = string
  description = "The id of the VPC"
}

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "The name of the AWS region where the cluster lives"
}

variable "deploy_metrics_server" {
  type        = bool
  description = "If AWS Metrics server should be deployed"
}

variable "cloudflare_api_key" {
  type        = string
  description = "Cloudflare API key"
}

variable "cloudflare_email" {
  type        = string
  description = "Cloudflare email"
}

variable "cluster_autoscaler_version" {
  type        = string
  description = "The version of the cluster autoscaler to deploy"
}

variable "aws_load_balancer_controller_chart_version" {
  description = "The AWS Load Balancer Controller chart version to use. See https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller for available versions"
  type        = string
  default     = "1.6.2"
}