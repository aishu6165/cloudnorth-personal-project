variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "alb_sg_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "public_subnet_1a_id" {
  description = "ID of public subnet 1a"
  type        = string
}

variable "public_subnet_1b_id" {
  description = "ID of public subnet 1b"
  type        = string
}

variable "alb_logs_bucket_name" {
  description = "S3 bucket name for ALB access logs"
  type        = string
}
