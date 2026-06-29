output "cluster_name" {
  description = "ECS cluster name, used by monitoring and CI/CD"
  value       = aws_ecs_cluster.main.name
}

output "service_name" {
  description = "ECS service name, used by CI/CD to trigger deployments"
  value       = aws_ecs_service.api.name
}

output "log_group_name" {
  description = "CloudWatch log group, check here when tasks fail to start"
  value       = aws_cloudwatch_log_group.ecs.name
}
