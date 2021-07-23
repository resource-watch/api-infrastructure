resource "random_id" "eks-node-group" {
  keepers = {
    # Generate a new id each time we make changes to the instance type
    # In case TF gets stuck during apply, we can taint this resource to force TF
    # to create a new random ID
    # `terraform taint module.core-node-group.random_id.eks_node_group`
    instance_types = join(",", var.instance_types)
    capacity_type  = var.capacity_type
  }
  byte_length = 8
}

resource "aws_eks_node_group" "eks-node-group" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.node_group_name}-${random_id.eks-node-group.hex}"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids
  release_version = var.eks_node_release_version
  capacity_type   = var.capacity_type

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = var.instance_types
  disk_size      = var.instance_disk_size

  labels = var.labels

  tags = {
    node_group_name = var.node_group_name
  }

  depends_on = [
    var.cluster
  ]

  lifecycle {
    ignore_changes        = [scaling_config[0].desired_size]
    create_before_destroy = true
  }
}

