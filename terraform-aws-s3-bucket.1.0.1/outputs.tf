output "bucket_name" {
  value       = aws_s3_bucket.default.id
  description = "Bucket Name"
}

output "bucket_arn" {
  value       = aws_s3_bucket.default.arn
  description = "Bucket ARN"
}