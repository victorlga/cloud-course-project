terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.6.0"
    }
  }
  required_version = ">= 1.0.0"
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

module "ec2" {
  source = "./modules/ec2"

  ami                     = "ami-0fc5d935ebf8bc3bc"
  instance_type           = "t2.micro"
  vpc_id                  = module.vpc.vpc_id
  public_sub_1_id         = module.vpc.public_sub_1_id
  public_sub_2_id         = module.vpc.public_sub_2_id
  private_sub_1_id        = module.vpc.private_sub_1_id
  private_sub_2_id        = module.vpc.private_sub_2_id
  ec2_sg_id               = module.sg.ec2_sg_id
  alb_sg_id               = module.sg.alb_sg_id
  db_endpoint             = module.rds.db_endpoint
  PATH_TO_YOUR_PUBLIC_KEY = "/home/victor/.ssh/id_rsa.pub"
}

module "rds" {
  source                  = "./modules/rds"
  rds_sg_id               = module.sg.rds_sg_id

  private_sub_1_id        = module.vpc.private_sub_1_id
  private_sub_2_id        = module.vpc.private_sub_2_id
  
  allocated_storage       = 10
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t2.micro"
  name                    = "mysql_db"
  username                = "username"
  password                = "super_secret_password"
  parameter_group_name    = "default.mysql8.0"
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Sun:04:00-Sun:05:00"
  multi_az                = true
}