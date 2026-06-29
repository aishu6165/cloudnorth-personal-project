variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID where endpoints will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block, used to allow inbound HTTPS to endpoints"
  type        = string
}

variable "private_app_subnet_1a_id" {
  description = "Private app subnet 1a, interface endpoints are placed here"
  type        = string
}

variable "private_app_subnet_1b_id" {
  description = "Private app subnet 1b, interface endpoints are placed here"
  type        = string
}

variable "private_route_table_id" {
  description = "Private route table ID, S3 gateway endpoint attaches here"
  type        = string
}
