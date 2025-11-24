resource "aws_s3_bucket" "receipt_images" {
  bucket = "${var.project_name}-receipt-images-${var.account_id}"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-receipt-images"
    }
  )
}

resource "aws_s3_bucket_versioning" "receipt_images" {
  bucket = aws_s3_bucket.receipt_images.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "receipt_images" {
  bucket = aws_s3_bucket.receipt_images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "receipt_images" {
  bucket = aws_s3_bucket.receipt_images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

