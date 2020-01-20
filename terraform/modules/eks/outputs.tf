output "cluster" {
  value = aws_eks_cluster.eks_cluster
}

output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority.0.data
}

locals {
  kubeconfig = <<KUBECONFIG
# see also: https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html

apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.eks_cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.eks_cluster.certificate_authority.0.data}
  name: ${aws_eks_cluster.eks_cluster.name}-${var.environment}
contexts:
- context:
    cluster: ${aws_eks_cluster.eks_cluster.name}-${var.environment}
    user: aws-rw-${var.environment}
  name: aws-rw-${var.environment}
kind: Config
preferences: {}
users:
- name: aws-rw-${var.environment}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--cluster-name"
        - "${aws_eks_cluster.eks_cluster.name}"
        # - "-r"
        # - "<role-arn>"
      # env:
        # - name: AWS_PROFILE
        #   value: "<aws-profile>"
KUBECONFIG
}

output "kubeconfig" {
  value = local.kubeconfig
}
