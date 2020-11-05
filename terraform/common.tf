resource "aws_iam_policy" "lambda_cloud_watch_policy" {
  name   = "lambda_cloud_watch_policy"
  policy = data.aws_iam_policy_document.lambda_cloud_watch_policy_document.json
}

data "aws_iam_policy" "lambda_vpc_access_managed_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy_document" "lambda_cloud_watch_policy_document" {
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

data "aws_iam_policy_document" "lambda_assume_role_policy_document" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

