data "aws_caller_identity" "current" {}

locals {
  # Builds the ECR image URI dynamically from the live account ID, no hardcoding needed
  container_image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/dev-api-app:latest"
}

module "networking" {
  source = "./modules/networking"

  environment                 = var.environment
  vpc_cidr                    = var.vpc_cidr
  availability_zone_1a        = var.availability_zone_1a
  availability_zone_1b        = var.availability_zone_1b
  public_subnet_cidr_1a       = var.public_subnet_cidr_1a
  public_subnet_cidr_1b       = var.public_subnet_cidr_1b
  private_app_subnet_cidr_1a  = var.private_app_subnet_cidr_1a
  private_app_subnet_cidr_1b  = var.private_app_subnet_cidr_1b
  private_data_subnet_cidr_1a = var.private_data_subnet_cidr_1a
  private_data_subnet_cidr_1b = var.private_data_subnet_cidr_1b
}

module "security_groups" {
  source = "./modules/security_groups"

  vpc_id      = module.networking.vpc_id # ← output from networking
  environment = var.environment
}

module "aws_ecr_repository" {
  source = "./modules/ecr"
  environment = var.environment
}

module "aws_iam" {
  source = "./modules/iam"
  environment = var.environment
  app_assets_bucket_arn = module.aws_s3_bucket.app_assets_bucket_arn
}

module "aws_s3_bucket" {
  source      = "./modules/s3"
  environment = var.environment
}

module "database" {
  source                    = "./modules/database"
  environment               = var.environment
  db_instance_class         = "db.t3.micro"
  private_data_subnet_1a_id = module.networking.private_data_subnet_1a_id
  private_data_subnet_1b_id = module.networking.private_data_subnet_1b_id
  db_security_group_id      = module.security_groups.db_sg_id
}

module "alb" {
  source               = "./modules/alb"
  environment          = var.environment
  vpc_id               = module.networking.vpc_id
  alb_sg_id            = module.security_groups.alb_sg_id
  public_subnet_1a_id  = module.networking.public_subnet_1a_id
  public_subnet_1b_id  = module.networking.public_subnet_1b_id
  alb_logs_bucket_name = module.aws_s3_bucket.alb_logs_bucket_name
}

module "vpc_endpoints" {
  source = "./modules/vpc_endpoints"

  environment              = var.environment
  vpc_id                   = module.networking.vpc_id
  vpc_cidr                 = var.vpc_cidr
  private_app_subnet_1a_id = module.networking.private_app_subnet_1a_id
  private_app_subnet_1b_id = module.networking.private_app_subnet_1b_id
  private_route_table_id   = module.networking.private_route_table_id
}

module "ecs" {
  source = "./modules/ecs"

  environment              = var.environment
  container_image          = local.container_image
  ecs_task_cpu             = var.ecs_task_cpu
  ecs_task_memory          = var.ecs_task_memory
  ecs_desired_count        = var.ecs_desired_count
  execution_role_arn       = module.aws_iam.execution_role_arn
  task_role_arn            = module.aws_iam.task_role_arn
  app_sg_id                = module.security_groups.app_sg_id
  private_app_subnet_1a_id = module.networking.private_app_subnet_1a_id
  private_app_subnet_1b_id = module.networking.private_app_subnet_1b_id
  target_group_arn         = module.alb.target_group_arn
  db_host                  = module.database.db_endpoint
  db_name                  = module.database.db_name
  db_secret_arn            = module.database.db_secret_arn
}