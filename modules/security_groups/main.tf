# TIER 1, Load Balancer

resource "aws_security_group" "alb" {
  name        =  "alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id


   tags = {
    Name        = "alb-sg"
    Environment = var.environment
  }
}

# Tier 2,Application servers (private app subnet)
resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "Security group for application servers"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "app-sg"
    Environment = var.environment
  }
}

# Tier 3,Database (private data subnet)
resource "aws_security_group" "db" {
  name        = "db-sg"
  description = "Security group for database"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "db-sg"
    Environment = var.environment
  }
}

# SECURITY GROUP RULES
# source_security_group_id and security_group_id only valid here
# NOT inside aws_security_group blocks
# Allow HTTP from internet → ALB
resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

# Allow HTTPS from internet → ALB
resource "aws_security_group_rule" "alb_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

# Allow ALB → app servers on port 8080
resource "aws_security_group_rule" "alb_egress_to_app" {
  type                     = "egress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  security_group_id        = aws_security_group.alb.id
}

# Allow ALB → app servers on port 8080
resource "aws_security_group_rule" "app_ingress_from_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.app.id
}

# Allow app servers → database on port 5432
resource "aws_security_group_rule" "app_egress_to_db" {
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.db.id
  security_group_id        = aws_security_group.app.id
}

# Allow app servers → database on port 5432
resource "aws_security_group_rule" "db_ingress_from_app" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  security_group_id        = aws_security_group.db.id
}

resource "aws_security_group_rule" "app_egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app.id
}
