output "s3_bucket_name" {
  description = "S3 버킷 이름 (영수증 이미지)"
  value       = aws_s3_bucket.receipt_images.id
}

output "s3_bucket_arn" {
  description = "S3 버킷 ARN"
  value       = aws_s3_bucket.receipt_images.arn
}

