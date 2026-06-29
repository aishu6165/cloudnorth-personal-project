resource "aws_db_subnet_group" "main" {
  name       = "cloudnorth-${var.environment}-db-subnet-group"
  subnet_ids = [var.private_data_subnet_1a_id, var.private_data_subnet_1b_id]

  tags = {
    Name        = "cloudnorth-db-subnet-group"
    Environment = var.environment
  }
}

resource "aws_db_parameter_group" "main" {
  name   = "cloudnorth-${var.environment}-pg15"
  family = "postgres15"

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  tags = {
    Name        = "cloudnorth-pg15"
    Environment = var.environment
  }
}

resource "aws_db_instance" "main" {
  identifier     = "cloudnorth-${var.environment}-db"
  engine         = "postgres"
  engine_version = "15"
  instance_class = var.db_instance_class
  db_name        = "cloudnorth"


  username                    = "cloudnorth_admin"
  manage_master_user_password = true

  # Storage
  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  # Network
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible    = false

  # Availability
  multi_az = true

  # Backups
  backup_retention_period = 7
  skip_final_snapshot     = true

  # Custom parameter group
  parameter_group_name = aws_db_parameter_group.main.name

  tags = {
    Name        = "cloudnorth-db"
    Environment = var.environment
  }
}
