resource "aws_ecr_repository" "api" {
  name                 = "${var.environment}-api-${var.repository_name}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "api-${var.repository_name}"
    Environment = var.environment
  }
}

resource "aws_ecr_repository" "web" {
  name                 = "${var.environment}-web-${var.repository_name}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "web-${var.repository_name}"
    Environment = var.environment
  }
}