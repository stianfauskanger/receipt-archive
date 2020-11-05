resource "random_id" "s3_bucket_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "photos_inbox" {
  bucket = "photos-inbox-${random_id.s3_bucket_suffix.hex}"
  acl    = "private"

  cors_rule {
    allowed_methods = ["POST"]
    allowed_origins = ["*"]
    allowed_headers = ["*"]
  }

  lifecycle_rule {
    enabled = true
    abort_incomplete_multipart_upload_days = 1
    expiration {
      days = 1
    }
  }

  tags = {
    Name            = "S3 bucket for temporary storage of uploaded photos of receipts"
    receipt-archive = 1
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.photos_inbox.id
  restrict_public_buckets = true
  ignore_public_acls = true
  block_public_acls   = true
  block_public_policy = true
}
