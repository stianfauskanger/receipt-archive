resource "aws_lambda_function" "upload-photo-lambda" {
  s3_bucket        = data.aws_s3_bucket_object.upload_photo_lambda_src_zip.bucket
  s3_key           = data.aws_s3_bucket_object.upload_photo_lambda_src_zip.key
  function_name    = "upload-photo-lambda"
  role             = aws_iam_role.iam_role_upload_photo_lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs12.x"
  source_code_hash = trimspace(data.aws_s3_bucket_object.upload_photo_lambda_src_zip_sha.body)

  vpc_config {
    security_group_ids = [aws_vpc.main.default_security_group_id]
    subnet_ids         = [aws_subnet.public_subnet_az_a.id, aws_subnet.public_subnet_az_b.id, aws_subnet.public_subnet_az_c.id]
  }

  //  environment {
  //    variables = {
  //      SOME_ENV_VAR = "TEST"
  //    }
  //  }

  tags = {
    Name            = "Lambda for uploading photo to S3"
    receipt-archive = 1
  }
}

data "aws_s3_bucket_object" "upload_photo_lambda_src_zip" {
  bucket = var.lambdas_s3_bucket
  key    = "${var.lambdas_s3_key}/upload-photo-lambda.zip"
}

data "aws_s3_bucket_object" "upload_photo_lambda_src_zip_sha" {
  bucket = var.lambdas_s3_bucket
  key    = "${var.lambdas_s3_key}/upload-photo-lambda.zip.base64sha256.txt"
}

resource "aws_iam_role" "iam_role_upload_photo_lambda" {
  name               = "iam_role_upload_photo_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "msk_updater_cw_lambda_logs_attachment" {
  role       = aws_iam_role.iam_role_upload_photo_lambda.name
  policy_arn = aws_iam_policy.lambda_cw_logs.arn
}

data "aws_iam_policy" "vpc_access_aws_managed_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "vpc_access_updater_lambda_msk_attachment" {
  role       = aws_iam_role.iam_role_upload_photo_lambda.name
  policy_arn = data.aws_iam_policy.vpc_access_aws_managed_policy.arn
}
