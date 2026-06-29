output "app_assets_bucket_name" {
    value = aws_s3_bucket.app_assets_s3.id
}

output "app_assets_bucket_arn" {
  value = aws_s3_bucket.app_assets_s3.arn
}

output "alb_logs_bucket_name" {
  value = aws_s3_bucket.alb_logs_s3.id
}
