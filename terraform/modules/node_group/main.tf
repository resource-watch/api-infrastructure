resource "aws_eks_node_group" "eks-node-group" {
  cluster_name    = var.cluster_name
  node_group_name = replace("${var.node_group_name}-${var.instance_types}", ".", "_")
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = [var.instance_types]
  disk_size      = var.instance_disk_size

  labels = var.labels

  depends_on = [
    var.cluster
  ]

  lifecycle {
    ignore_changes        = [scaling_config[0].desired_size]
    create_before_destroy = true
  }
}
