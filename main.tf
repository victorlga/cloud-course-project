terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
  }
  required_version = "= 1.6.3"

  backend "s3" {
    bucket         = "bucket-terraform-victor"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}


data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr              = "10.0.0.0/16"
  public_sub_1_cidr     = "10.0.1.0/24"
  public_sub_2_cidr     = "10.0.2.0/24"
  private_sub_1_cidr    = "10.0.3.0/24"
  private_sub_2_cidr    = "10.0.4.0/24"
  availability_zone_1   = data.aws_availability_zones.available.names[0]
  availability_zone_2   = data.aws_availability_zones.available.names[1]
}

module "sg" {
  source = "./modules/security_groups"

  vpc_id = module.vpc.vpc_id
}

module "iam" {
  source = "./modules/iam"
}

data "aws_secretsmanager_secret" "db_credentials" {
  name = "app/mysql/credentials"
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.db_credentials.id
}

locals {
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)
}

module "ec2" {
  source                      = "./modules/ec2"

  ami                         = "ami-0fc5d935ebf8bc3bc"
  instance_type               = "t2.micro"

  vpc_id                      = module.vpc.vpc_id
  public_sub_1_id             = module.vpc.public_sub_1_id
  public_sub_2_id             = module.vpc.public_sub_2_id
  private_sub_1_id            = module.vpc.private_sub_1_id
  private_sub_2_id            = module.vpc.private_sub_2_id

  ec2_sg_id                   = module.sg.ec2_sg_id
  alb_sg_id                   = module.sg.alb_sg_id

  db_name                     = local.db_credentials.name
  db_username                 = local.db_credentials.username
  db_password                 = local.db_credentials.password
  db_host                     = module.rds.db_host

  ec2_profile_name            = module.iam.ec2_profile_name
}

module "rds" {
  source                  = "./modules/rds"

  rds_sg_id               = module.sg.rds_sg_id

  private_sub_1_id        = module.vpc.private_sub_1_id
  private_sub_2_id        = module.vpc.private_sub_2_id
  
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t2.micro"
  parameter_group_name    = "default.mysql8.0"

  db_name                 = local.db_credentials.name
  username                = local.db_credentials.username
  password                = local.db_credentials.password
  
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Sun:04:00-Sun:05:00"
  multi_az                = true
}

module "locust" {
  source              = "./modules/locust"

  ami                 = "ami-0fc5d935ebf8bc3bc"
  instance_type       = "t2.micro"
  public_sub_1_id     = module.vpc.public_sub_1_id
  loc_sg_id           = module.sg.loc_sg_id
  lb_endpoint         = module.ec2.lb_endpoint 
}