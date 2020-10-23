data "archive_file" "lambda_eks_scaling" {
  type        = "zip"
  source_dir  = "../lambda/eks_scaling/src"
  output_path = "../lambda/eks_scaling/lambda.zip"
}