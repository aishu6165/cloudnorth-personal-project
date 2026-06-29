output "alb_dns_name" {
  description = "Hit this URL to reach the app"
  value       = module.alb.alb_dns_name
}

output "ecs_cluster_name" {
  description = "ECS cluster name, useful for AWS console and CLI"
  value       = module.ecs.cluster_name
}

output "ecs_log_group" {
  description = "CloudWatch log group, check here when tasks fail"
  value       = module.ecs.log_group_name
}
