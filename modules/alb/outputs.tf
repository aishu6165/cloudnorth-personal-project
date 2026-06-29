output "alb_dns_name" {
  description = "DNS name of the ALB,use this to hit the app"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the ALB,used by monitoring module"
  value       = aws_lb.main.arn
}

output "target_group_arn" {
  description = "ARN of the target group,ECS registers tasks here"
  value       = aws_lb_target_group.app.arn
}
