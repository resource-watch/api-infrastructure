data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

provider "kubectl" {
  host = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  token = data.aws_eks_cluster_auth.cluster.token
  load_config_file = false
}

// https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
// ALB Ingress Controller v1.1.8
// RBAC roles file is as-is
// Main file has changes - see link above for details
resource "kubectl_manifest" "alb_ingress_controller_rbac_role" {
  yaml_body = file("${path.module}/alb_ingress/rbac-role.yaml")
}

resource "kubectl_manifest" "alb_ingress_controller_main" {
  yaml_body = templatefile("${path.module}/alb_ingress/alb-ingress-controller.yaml.tmpl", {
    vpc_id: var.vpc_id,
    aws_region: var.aws_region,
    cluster_name: var.cluster_name
  })
}

// https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html
// AWS Cluster autoscaler
// File has changes - see link above for details
resource "kubectl_manifest" "cluster_autoscaler" {
  yaml_body = templatefile("${path.module}/cluster_autoscaler/cluster-autoscaler-autodiscover.yaml.tmpl", {
    cluster_name: var.cluster_name
  })
}

// https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html
// AWS Metrics server for HPA support
// File has no changes
resource "kubectl_manifest" "metrics-server" {
  yaml_body = file("${path.module}/metrics_server/metrics_server.yaml")
}

// https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-EKS-quickstart.html
// Container insights
// File has changes - see link above for details
resource "kubectl_manifest" "container_insights" {
  yaml_body = templatefile("${path.module}/container_insights/container_insights.yaml.tmpl", {
    aws_region: var.aws_region,
    cluster_name: var.cluster_name
  })
}