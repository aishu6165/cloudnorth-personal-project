variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "aws_region" {
  description = "AWS region, used for CloudWatch log config"
  type        = string
  default     = "us-east-1"
}

variable "container_image" {
  description = "Full ECR image URI including tag, e.g. 123456789.dkr.ecr.us-east-1.amazonaws.com/dev-cloudnorth-api:latest"
  type        = string
}

variable "ecs_task_cpu" {
  description = "CPU units for the task (256, 512, 1024...)"
  type        = number
  default     = 512
}

variable "ecs_task_memory" {
  description = "Memory in MB for the task"
  type        = number
  default     = 1024
}

variable "ecs_desired_count" {
  description = "Number of tasks to run"
  type        = number
  default     = 2
}

variable "execution_role_arn" {
  description = "IAM role ARN for ECS to pull images and write logs"
  type        = string
}

variable "task_role_arn" {
  description = "IAM role ARN for the running container (S3, Secrets Manager access)"
  type        = string
}

variable "app_sg_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "private_app_subnet_1a_id" {
  description = "Private app subnet 1a, tasks run here"
  type        = string
}

variable "private_app_subnet_1b_id" {
  description = "Private app subnet 1b, tasks run here"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN, service registers tasks here"
  type        = string
}

variable "db_host" {
  description = "RDS endpoint, passed to container as DB_HOST"
  type        = string
}

variable "db_name" {
  description = "Database name, passed to container as DB_NAME"
  type        = string
}

variable "db_secret_arn" {
  description = "Secrets Manager ARN for RDS password, ECS injects DB_PASSWORD from here"
  type        = string
}
