#// https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
#// ALB Ingress Controller
module "alb" {
  source       = "./alb_ingress"
  aws_region   = var.aws_region
  cluster_name = var.cluster_name
  aws_load_balancer_controller_chart_version = var.aws_load_balancer_controller_chart_version
}

data "aws_caller_identity" "current" {}

// https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html
// AWS Cluster autoscaler
// File has changes - see link above for details
data "kubectl_path_documents" "cluster_autoscaler_manifests" {
  pattern = "${path.module}/cluster_autoscaler/cluster-autoscaler-autodiscover.yaml.tmpl"
  vars = {
    cluster_name : var.cluster_name
    aws_account_id : data.aws_caller_identity.current.account_id
    cluster_autoscaler_version: var.cluster_autoscaler_version
  }
}

resource "kubectl_manifest" "cluster_autoscaler" {
  count     = length(data.kubectl_path_documents.cluster_autoscaler_manifests.documents)
  yaml_body = element(data.kubectl_path_documents.cluster_autoscaler_manifests.documents, count.index)
}

// https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html
// AWS Metrics server for HPA support
// File has no changes
data "kubectl_path_documents" "metrics_server_manifests" {
  pattern = "${path.module}/metrics_server/metrics_server.yaml"
}

resource "kubectl_manifest" "metrics_server" {
  count     = var.deploy_metrics_server ? length(data.kubectl_path_documents.metrics_server_manifests.documents) : 0
  yaml_body = element(data.kubectl_path_documents.metrics_server_manifests.documents, count.index)
}

// https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-EKS-quickstart.html
// Container insights
// File has changes - see link above for details
data "kubectl_path_documents" "container_insights_manifests" {
  pattern = "${path.module}/container_insights/container_insights.yaml.tmpl"
  vars = {
    aws_region : var.aws_region,
    cluster_name : var.cluster_name
  }
}

resource "kubectl_manifest" "container_insights" {
  count     = length(data.kubectl_path_documents.container_insights_manifests.documents)
  yaml_body = element(data.kubectl_path_documents.container_insights_manifests.documents, count.index)
}

// https://docs.aws.amazon.com/eks/latest/userguide/cni-upgrades.html
// AWS VPC CNI plugin for Kubernetes
// File has changes - see link above for details
data "kubectl_path_documents" "cni_plugin_manifests" {
  pattern = "${path.module}/cni_plugin/aws-k8s-cni.yaml"
}

resource "kubectl_manifest" "cni_plugin" {
  count     = length(data.kubectl_path_documents.cni_plugin_manifests.documents)
  yaml_body = element(data.kubectl_path_documents.cni_plugin_manifests.documents, count.index)
}

module "node_termination_handler" {
  source = "./node_termination_handler"
}
