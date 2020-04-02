data "aws_iam_policy_document" "eks-admin-EKSManagerPolicy-document" {
  source_json = file("${path.module}/eks_manager.json")
}
