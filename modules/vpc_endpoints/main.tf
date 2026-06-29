# Security group for interface endpoints
# Allows HTTPS from anywhere inside the VPC so ECS tasks can reach endpoints
resource "aws_security_group" "endpoints" {
  name        = "vpc-endpoints-sg-${var.environment}"
  description = "Allow HTTPS from within VPC to interface endpoints"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "vpc-endpoints-sg"
    Environment = var.environment
  }
}

# S3 Gateway endpoint — free, no SG needed, attaches to route table
# ECR pulls image layers from S3, this is required alongside ecr.dkr
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [var.private_route_table_id]

  tags = {
    Name        = "cloudnorth-s3-endpoint"
    Environment = var.environment
  }
}

# ECR API endpoint — handles DescribeImages, GetAuthorizationToken etc
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.private_app_subnet_1a_id, var.private_app_subnet_1b_id]
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "cloudnorth-ecr-api-endpoint"
    Environment = var.environment
  }
}

# ECR DKR endpoint — handles actual Docker image layer pulls
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.private_app_subnet_1a_id, var.private_app_subnet_1b_id]
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "cloudnorth-ecr-dkr-endpoint"
    Environment = var.environment
  }
}

# Secrets Manager endpoint — ECS injects DB_PASSWORD at task startup from here
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.private_app_subnet_1a_id, var.private_app_subnet_1b_id]
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "cloudnorth-secretsmanager-endpoint"
    Environment = var.environment
  }
}

# CloudWatch Logs endpoint — container stdout/stderr ships here
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.private_app_subnet_1a_id, var.private_app_subnet_1b_id]
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "cloudnorth-logs-endpoint"
    Environment = var.environment
  }
}
