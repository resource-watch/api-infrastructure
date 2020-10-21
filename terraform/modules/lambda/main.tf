
# Create the Lambda function
resource "aws_lambda_function" "eks_scaling" {
  function_name = "eks_scaling"
  description   = "Upscale or downscale EKS cluster"
  handler       = "eks_scaling.lambda_handler"
  runtime       = var.lambda_eks_scaling_python_runtime

  role        = aws_iam_role.lambda_exec_role.arn
  memory_size = 128
  timeout     = 300

  source_code_hash = data.archive_file.lambda_eks_scaling.output_base64sha256
  filename         = data.archive_file.lambda_eks_scaling.output_path
}

# Create the Cloudwatch event rule (just the "schedule")
resource "aws_cloudwatch_event_rule" "every_thirty_minutes" {
  name                = "every-thirty-minutes"
  description         = "Fires every thirty minutes"
  schedule_expression = "rate(30 minutes)"
}

# Associate the event rule with the Lambda function
resource "aws_cloudwatch_event_target" "check_cluster_scaling_every_thirty_minutes" {
  rule      = aws_cloudwatch_event_rule.every_thirty_minutes.name
  target_id = "lambda"
  arn       = aws_lambda_function.eks_scaling.arn
}

# Give Cloudwatch permission to run the function
resource "aws_lambda_permission" "allow_cloudwatch_to_call_eks_scaling" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.eks_scaling.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_thirty_minutes.arn
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_exec_role" {
  name               = "lambda_exec_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

# Create an IAM policy for the Lambda function
resource "aws_iam_policy" "lambda_iam_policy" {
  name   = "lambda_iam_policy"
  policy = data.aws_iam_policy_document.lambda_policy_doc.json
}

# Associate the policy with the function's IAM role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_iam_policy.arn
  role       = aws_iam_role.lambda_exec_role.name
}
