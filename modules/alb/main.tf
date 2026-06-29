resource "aws_lb" "main" {
  name               = "cloudnorth-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = [var.public_subnet_1a_id, var.public_subnet_1b_id]

  access_logs {
    bucket  = var.alb_logs_bucket_name
    prefix  = "alb"
    enabled = true
  }

  tags = {
    Name        = "cloudnorth-alb"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "app" {
  name        = "cloudnorth-${var.environment}-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name        = "cloudnorth-tg"
    Environment = var.environment
  }
}

# HTTP listener,redirects to HTTPS
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# App listener,forwards to target group (HTTP until ACM cert is added)
resource "aws_lb_listener" "http_app" {
  load_balancer_arn = aws_lb.main.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
