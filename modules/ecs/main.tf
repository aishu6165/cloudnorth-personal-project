# CloudWatch Log Group, container stdout/stderr lands here
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/cloudnorth-${var.environment}"
  retention_in_days = 30

  tags = {
    Name        = "cloudnorth-ecs-logs"
    Environment = var.environment
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "cloudnorth-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "cloudnorth-cluster"
    Environment = var.environment
  }
}

# Task Definition, describes the container: image, CPU, memory, ports, env vars, logging
resource "aws_ecs_task_definition" "api" {
  family                   = "cloudnorth-${var.environment}-api"
  network_mode             = "awsvpc"       
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = var.execution_role_arn  
  task_role_arn            = var.task_role_arn       

  container_definitions = jsonencode([{
    name      = "cloudnorth-api"
    image     = var.container_image
    essential = true

    portMappings = [{
      containerPort = 8080
      protocol      = "tcp"
    }]

    # Plain env vars, non-sensitive config
    environment = [
      { name = "ENVIRONMENT", value = var.environment },
      { name = "DB_HOST",     value = var.db_host },
      { name = "DB_NAME",     value = var.db_name },
      { name = "DB_USER",     value = "cloudnorth_admin" },
      { name = "PORT",        value = "8080" },
    ]

    # Secrets, ECS pulls these from Secrets Manager at task startup
    # DB_PASSWORD comes from the JSON secret RDS created automatically
    secrets = [{
      name      = "DB_PASSWORD"
      valueFrom = "${var.db_secret_arn}:password::"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "api"
      }
    }
  }])

  tags = {
    Name        = "cloudnorth-api-task"
    Environment = var.environment
  }
}

# ECS Service, keeps desired_count tasks running and registers them with the ALB
resource "aws_ecs_service" "api" {
  name            = "cloudnorth-${var.environment}-api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"

  force_new_deployment = true

  network_configuration {
    subnets          = [var.private_app_subnet_1a_id, var.private_app_subnet_1b_id]
    security_groups  = [var.app_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "cloudnorth-api"
    container_port   = 8080
  }

  tags = {
    Name        = "cloudnorth-api-service"
    Environment = var.environment
  }
}

# Auto Scaling Target, registers the ECS service as something that can be scaled
resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = 10
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Auto Scaling Policy, target 60% CPU, scale in when below 30%
resource "aws_appautoscaling_policy" "ecs_cpu" {
  name               = "cloudnorth-${var.environment}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 60.0
    scale_in_cooldown  = 300   
    scale_out_cooldown = 60    
  }
}
