variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "public_subnet_cidr_1a" {
  description = "CIDR block for public subnet 1a"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_cidr_1b" {
  description = "CIDR block for public subnet 1b"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_app_subnet_cidr_1a" {
  description = "CIDR block for private app subnet 1a"
  type        = string
  default     = "10.0.10.0/24"
}

variable "private_app_subnet_cidr_1b" {
  description = "CIDR block for private app subnet 1b"
  type        = string
  default     = "10.0.11.0/24"
}

variable "private_data_subnet_cidr_1a" {
  description = "CIDR block for private data subnet 1a"
  type        = string
  default     = "10.0.20.0/24"
}

variable "private_data_subnet_cidr_1b" {
  description = "CIDR block for private data subnet 1b"
  type        = string
  default     = "10.0.21.0/24"
}

variable "availability_zone_1a" {
  description = "Availability zone 1a"
  type        = string
  default     = "us-east-1a"
}

variable "availability_zone_1b" {
  description = "Availability zone 1b"
  type        = string
  default     = "us-east-1b"
}
