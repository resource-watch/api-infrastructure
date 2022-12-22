data "aws_iam_policy_document" "eks-admin-EKSManagerPolicy-document" {
  source_policy_documents = [file("${path.module}/eks_manager.json")]
}
