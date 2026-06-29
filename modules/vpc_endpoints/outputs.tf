output "secretsmanager_endpoint_id" {
  description = "Secrets Manager VPC endpoint ID"
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "s3_endpoint_id" {
  description = "S3 gateway endpoint ID"
  value       = aws_vpc_endpoint.s3.id
}
