# Configure aws provider

provider "aws" {
  region = var.region
}

# Create VPC

module "vpc" {
  source                           = "../modules/vpc"
  region                           = var.region 
  project_name                     = var.project_name
  vpc_cidr                         = var.vpc_cidr
  public_subnet_az1_cidr           = var.public_subnet_az1_cidr
  public_subnet_az2_cidr           = var.public_subnet_az2_cidr
  private_app_subnet_az1_cidr      = var.private_app_subnet_az1_cidr
  private_app_subnet_az2_cidr      = var.private_app_subnet_az2_cidr
  private_data_subnet_az1_cidr     = var.private_data_subnet_az1_cidr
  private_data_subnet_az2_cidr     = var.private_data_subnet_az2_cidr
}

# create nat gateways

module "nat_gateway" {
  source                        = "../modules/nat_gateway"
  public_subnet_az1_id          = module.vpc.public_subnet_az1_id
  internet_gateway              = module.vpc.internet_gateway
  public_subnet_az2_id          = module.vpc.public_subnet_az2_id
  vpc_id                        = module.vpc.vpc_id
  private_app_subnet_az1_id     = module.vpc.private_app_subnet_az1_id
  private_data_subnet_az1_id    = module.vpc.private_data_subnet_az1_id
  private_app_subnet_az2_id     = module.vpc.private_app_subnet_az2_id
  private_data_subnet_az2_id    = module.vpc.private_data_subnet_az2_id
}

# create security groups

module "security_group" {
  source = "../modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

# create iam role

module "ecs_task_execution_role" {
  source        = "../modules/ecs_task_execution_role"
  project_name  = module.vpc.project_name
}

# create acm 

module "acm" {
  source = "../modules/acm"
  domain_name       = var.domain_name
  alternative_name  = var.alternative_name
}


# create application load balancer

module "application_load_balancer" {
  source                = "../modules/alb"
  project_name          = module.vpc.project_name
  alb_security_group_id = module.security_group.alb_security_group_id
  public_subnet_az1_id  = module.vpc.public_subnet_az1_id
  public_subnet_az2_id  = module.vpc.public_subnet_az2_id
  vpc_id                = module.vpc.vpc_id
  certificate_arn       = module.acm.certificate_arn
}

# create rds

module "my_rds_instance" {
  source                   = "../modules/rds"
  db_instance_identifier  = var.db_instance_identifier
  db_username             = var.db_username
  db_password             = var.db_password
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = var.vpc_security_group_ids
  availability_zone       = var.private_data_subnet_az1_cidr
  db_name                 = var.db_name
  skip_final_snapshot     = var.skip_final_snapshot
}