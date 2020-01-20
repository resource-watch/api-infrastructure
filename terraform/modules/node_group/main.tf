resource "aws_eks_node_group" "eks-node-group-admin" {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks-node-group-admin.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = [var.instance_types]

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    var.cluster,
    aws_iam_role_policy_attachment.eks-node-group-admin-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-node-group-admin-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-node-group-admin-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "eks-node-group-admin" {
  name = "eks-node-group-admin"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

data "aws_iam_policy_document" "eks-admin-ALBIngressControllerIAMPolicy-document" {
  source_json = file("${path.module}/iam-policy.json")
}

resource "aws_iam_policy" "eks-admin-ALBIngressControllerIAMPolicy" {
  name   = "ALBIngressControllerIAMPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.eks-admin-ALBIngressControllerIAMPolicy-document.json
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy_attachment" "eks-admin-ALBIngressControllerIAMPolicy" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ALBIngressControllerIAMPolicy"
  role       = aws_iam_role.eks-node-group-admin.name
}

resource "aws_iam_role_policy_attachment" "eks-node-group-admin-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-node-group-admin.name
}

resource "aws_iam_role_policy_attachment" "eks-node-group-admin-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-node-group-admin.name
}

resource "aws_iam_role_policy_attachment" "eks-node-group-admin-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-node-group-admin.name
}