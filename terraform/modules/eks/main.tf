#
# EKS resources
#

locals {
  oicd_id = element(split("/", aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer), length(split("/", aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer)) - 1)
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "${replace(var.project, " ", "-")}-k8s-cluster-${var.environment}"
  role_arn = aws_iam_role.eks-cluster-admin.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    # At the time of this writing, AWS wasn't accepting EKS on us-east-1e
    security_group_ids      = [aws_security_group.eks_cluster_security_group.id]
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-admin-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-admin-AmazonEKSServicePolicy,
  ]
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.eks_cluster.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = var.ebs_csi_addon_version
  service_account_role_arn = aws_iam_role.ebs_csi_iam_role.arn
}

resource "aws_security_group" "eks_cluster_security_group" {
  name        = "${replace(var.project, " ", "-")}eks-cluster-security-group"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${replace(var.project, " ", "-")}-k8s-cluster-security-group"
  }
}

resource "aws_security_group_rule" "eks_cluster_cluster_ingress_workstation_https" {
  cidr_blocks       = ["0.0.0.0/0"]
  # TODO: restrict for improved security
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_cluster_security_group.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_iam_role" "eks-cluster-admin" {
  name = "${replace(var.project, " ", "-")}-eks-cluster-admin-role"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-admin-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-admin.name
}

resource "aws_iam_role_policy_attachment" "eks-admin-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-cluster-admin.name
}

data "external" "thumbprint" {
  program = [format("%s/bin/get_thumbprint.sh", path.module), var.aws_region]
}

resource "aws_iam_openid_connect_provider" "example" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.external.thumbprint.result.thumbprint]
  url             = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
}

#
# Node Group shared resources
#
resource "aws_iam_role" "eks-node-group-iam-role" {
  name = "eks-node-group-admin"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
}

data "aws_iam_policy_document" "eks-admin-ALBIngressControllerIAMPolicy-document" {
  source_policy_documents = [file("${path.module}/alb-ingress-controller-iam-policy.json")]
}

resource "aws_iam_policy" "eks-admin-ALBIngressControllerIAMPolicy" {
  name   = "ALBIngressControllerIAMPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.eks-admin-ALBIngressControllerIAMPolicy-document.json
}

data "aws_iam_policy_document" "eks-admin-ClusterAutoscaleAccessPolicy-document" {
  source_policy_documents = [file("${path.module}/cluster-autoscale-access-policy.json")]
}

data "aws_iam_policy_document" "eks-admin-DatabaseBackupToS3-document" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${var.backups_bucket}/*"
    ]
  }

  statement {
    actions = [
      "s3:ListBucketMultipartUploads",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts"
    ]
    resources = [
      "arn:aws:s3:::${var.backups_bucket}",
      "arn:aws:s3:::${var.backups_bucket}/*"
    ]
  }

  statement {
    actions = [
      "s3:ListBucket"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "eks-admin-ClusterAutoscaleAccessPolicy" {
  name   = "ClusterAutoscaleAccessPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.eks-admin-ClusterAutoscaleAccessPolicy-document.json
}

resource "aws_iam_policy" "eks-admin-DatabaseBackupToS3Policy" {
  name   = "DatabaseBackupToS3Policy"
  path   = "/"
  policy = data.aws_iam_policy_document.eks-admin-DatabaseBackupToS3-document.json
}

data "aws_iam_policy_document" "eks-admin-APIGatewayAccessPolicy-document" {
  source_policy_documents = [file("${path.module}/api-gateway-access-policy.json")]
}

resource "aws_iam_policy" "eks-admin-APIGatewayAccessPolicy" {
  name   = "APIGatewayAccessPolicy"
  policy = data.aws_iam_policy_document.eks-admin-APIGatewayAccessPolicy-document.json
}

resource "aws_iam_role" "ebs_csi_iam_role" {
  name = "AmazonEKS_EBS_CSI_DriverRole"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${var.aws_region}.amazonaws.com/id/${local.oicd_id}"
        },
        Action : "sts:AssumeRoleWithWebIdentity",
        Condition : {
          StringEquals : {
            "oidc.eks.${var.aws_region}.amazonaws.com/id/${local.oicd_id}:aud" : "sts.amazonaws.com",
            "oidc.eks.${var.aws_region}.amazonaws.com/id/${local.oicd_id}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy_attachment" "eks-admin-ALBIngressControllerIAMPolicy" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ALBIngressControllerIAMPolicy"
  role       = aws_iam_role.eks-node-group-iam-role.name
}

resource "aws_iam_role_policy_attachment" "eks-admin-ClusterAutoscaleAccessPolicy" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ClusterAutoscaleAccessPolicy"
  role       = aws_iam_role.eks-node-group-iam-role.name
}

resource "aws_iam_role_policy_attachment" "eks-admin-DatabaseBackupToS3Policy" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/DatabaseBackupToS3Policy"
  role       = aws_iam_role.eks-node-group-iam-role.name
}

resource "aws_iam_role_policy_attachment" "eks-node-group-admin-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-node-group-iam-role.name
}

resource "aws_iam_role_policy_attachment" "eks-node-group-admin-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-node-group-iam-role.name
}

resource "aws_iam_role_policy_attachment" "eks-node-group-admin-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-node-group-iam-role.name
}

resource "aws_iam_role_policy_attachment" "eks-node-group-admin-CloudWatchAgentServerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.eks-node-group-iam-role.name
}

resource "aws_iam_role_policy_attachment" "ebs-csi-service-role-AmazonEKS_EBS_CSI_DriverRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_iam_role.name
}

resource "aws_iam_role_policy_attachment" "eks-node-group-admin-AmazonEKS_EBS_CSI_DriverRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks-node-group-iam-role.name
}

resource "aws_iam_role_policy_attachment" "eks-node-group-admin-APIGatewayAccessPolicy" {
  policy_arn = aws_iam_policy.eks-admin-APIGatewayAccessPolicy.arn
  role       = aws_iam_role.eks-node-group-iam-role.name
}