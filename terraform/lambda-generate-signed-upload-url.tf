resource "aws_lambda_function" "generate_signed_upload_url_lambda" {
  s3_bucket        = data.aws_s3_bucket_object.generate_signed_upload_url_lambda_src_zip.bucket
  s3_key           = data.aws_s3_bucket_object.generate_signed_upload_url_lambda_src_zip.key
  function_name    = "generate_signed_upload_url_lambda"
  role             = aws_iam_role.iam_role_generate_signed_upload_url_lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs12.x"
  source_code_hash = trimspace(data.aws_s3_bucket_object.generate_signed_upload_url_lambda_src_zip_sha.body)

  vpc_config {
    security_group_ids = [aws_vpc.main_vpc.default_security_group_id]
    subnet_ids         = [aws_subnet.public_subnet_az_a.id, aws_subnet.public_subnet_az_b.id, aws_subnet.public_subnet_az_c.id]
  }

  environment {
    variables = {
      S3_PHOTO_INBOX_ID = aws_s3_bucket.photos_inbox.id
    }
  }

  tags = {
    Name            = "Lambda for generating an S3 pre-signed POST url"
    receipt-archive = 1
  }
}

data "aws_s3_bucket_object" "generate_signed_upload_url_lambda_src_zip" {
  bucket = var.lambdas_s3_bucket
  key    = "${var.lambdas_s3_key}/generate-signed-upload-url-lambda.zip"
}

data "aws_s3_bucket_object" "generate_signed_upload_url_lambda_src_zip_sha" {
  bucket = var.lambdas_s3_bucket
  key    = "${var.lambdas_s3_key}/generate-signed-upload-url-lambda.zip.base64sha256.txt"
}

resource "aws_iam_role" "iam_role_generate_signed_upload_url_lambda" {
  name               = "iam_role_generate_signed_upload_url_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_document.json
}

resource "aws_iam_role_policy_attachment" "generate_signed_upload_url_lambda_cloud_watch_policy_attachment" {
  role       = aws_iam_role.iam_role_generate_signed_upload_url_lambda.name
  policy_arn = aws_iam_policy.lambda_cloud_watch_policy.arn
}

resource "aws_iam_role_policy_attachment" "generate_signed_upload_url_lambda_vpc_access_policy_attachment" {
  role       = aws_iam_role.iam_role_generate_signed_upload_url_lambda.name
  policy_arn = data.aws_iam_policy.lambda_vpc_access_managed_policy.arn
}

// TODO: restrict this to what is needed
data "aws_iam_policy_document" "generate_signed_upload_url_lambda_access_s3_policy_document" {
  version = "2012-10-17"
  statement {
    sid = "S3AllowAll"
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.photos_inbox.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.photos_inbox.bucket}/*"
    ]
  }
}

resource "aws_iam_policy" "generate_signed_upload_url_lambda_access_s3_policy" {
  name   = "generate_signed_upload_url_lambda_access_s3_policy"
  policy = data.aws_iam_policy_document.generate_signed_upload_url_lambda_access_s3_policy_document.json
}

resource "aws_iam_role_policy_attachment" "generate_signed_upload_url_lambda_s3_access_policy_attachment" {
  role       = aws_iam_role.iam_role_generate_signed_upload_url_lambda.name
  policy_arn = aws_iam_policy.generate_signed_upload_url_lambda_access_s3_policy.arn
}

output "generate_signed_upload_url_endpoint" {
  value = "${aws_apigatewayv2_stage.prod.invoke_url}${var.get_upload_receipt_url_path}"
}
