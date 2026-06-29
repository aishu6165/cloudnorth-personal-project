variable "vpc_id" {
  description = "VPC ID from networking module"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  # default = "dev"
}