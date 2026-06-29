# AWS uses this to START the container
# Allows: pull image from ECR, write logs to CloudWatch
resource "aws_iam_role" "ecs_execution" {
  name = "cloudnorth-${var.environment}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = {
    Name        = "ecs-execution-role"
    Environment = var.environment
  }
}

# Attach AWS managed policy to execution role
# This policy already exists in AWS , gives exactly what ECS needs

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#Running container →  uses task role      →  reads from S3 etc
resource "aws_iam_role" "ecs_task" {
  name = "cloudnorth-${var.environment}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = {
    Name        = "ecs-task-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "ecs_execution_secrets" {
  name = "secrets-manager-read"
  role = aws_iam_role.ecs_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "secretsmanager:GetSecretValue"
      Resource = "arn:aws:secretsmanager:us-east-1:*:secret:cloudnorth/*"
    }]
  })
}