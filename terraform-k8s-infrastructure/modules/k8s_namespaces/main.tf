data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

resource "kubernetes_namespace" "namespaces" {
  count = length(var.namespaces)

  metadata {
    name = var.namespaces[count.index]
  }
}

# Ensure each namespace has a corresponding service account for the EKS cluster
# Note this is currently sharing the same IAM role that is attached to each node in the EKS cluster.
# It would be preferred to create a separate IAM role for each service account or each deployment.
data "aws_caller_identity" "current" {}

data "kubectl_path_documents" "namespace_serviceaccount_manifests" {
  pattern = "${path.module}/namespace-serviceaccount.yaml.tmpl"
  vars = {
    aws_account_id : data.aws_caller_identity.current.account_id
    namespaces : join(",", var.namespaces)
  }
}

resource "kubectl_manifest" "service_accounts" {
  for_each = data.kubectl_path_documents.namespace_serviceaccount_manifests.manifests
  yaml_body = each.value
}