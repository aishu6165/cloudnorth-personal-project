variable "repository_name" {
    description = "Name of the repo"
    type = string
    default = "app"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default = "dev"
}

