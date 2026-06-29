
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
}