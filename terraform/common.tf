resource "aws_iam_policy" "lambda_cw_logs" {
  name   = "lambda_cw_logs"
  policy = data.aws_iam_policy_document.lambda_cloud_watch_policies.json
}

data "aws_iam_policy_document" "lambda_cloud_watch_policies" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}


data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

