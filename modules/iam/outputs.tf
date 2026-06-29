output "execution_role_arn" {
  description = "ARN of ECS execution role - used by ECS module"
  value       = aws_iam_role.ecs_execution.arn
}

output "task_role_arn" {
  description = "ARN of ECS task role - used by ECS module"
  value       = aws_iam_role.ecs_task.arn
}