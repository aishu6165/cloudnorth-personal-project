variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "private_data_subnet_1a_id" {
  description = "ID of private data subnet 1a"
  type        = string
}

variable "private_data_subnet_1b_id" {
  description = "ID of private data subnet 1b"
  type        = string
}

variable "db_security_group_id" {
  description = "ID of the database security group"
  type        = string
}
