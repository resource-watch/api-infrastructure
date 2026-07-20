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
    namespaces : join(",", concat(var.namespaces, ["default"]))
  }
}

resource "kubectl_manifest" "service_accounts" {
  for_each = data.kubectl_path_documents.namespace_serviceaccount_manifests.manifests
  yaml_body = each.value
}

# Add it to the default SA in the all namespaces as well, to avoid having to change Jenkins deployments.
resource "kubernetes_annotations" "default_service_account" {
  count = length(var.namespaces)
  api_version = "v1"
  kind        = "ServiceAccount"
  metadata {
    name = "default"
    namespace = var.namespaces[count.index]
  }
  annotations = {
    "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/eks-node-group-admin"
  }
}

# And the default namespace
resource "kubernetes_annotations" "default_service_account_default_namespace" {
  api_version = "v1"
  kind        = "ServiceAccount"
  metadata {
    name = "default"
    namespace = "default"
  }
  annotations = {
    "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/eks-node-group-admin"
  }
}