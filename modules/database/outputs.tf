output "db_endpoint" {
  description = "RDS instance endpoint — used by ECS to connect"
  value       = aws_db_instance.main.endpoint
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

output "db_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the DB password"
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}
