# Stage 1: Networking Infrastructure
# VPC, Subnets, Internet Gateway, Route Tables

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

locals {
  availability_zones = data.aws_availability_zones.available.names
  account_id        = data.aws_caller_identity.current.account_id
}

# VPC Module
module "vpc" {
  source = "../modules/networking/vpc"
  
  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags                 = var.common_tags
}

# Public Subnet Module
module "public_subnet" {
  source = "../modules/networking/public_subnet"
  
  vpc_id                  = module.vpc.vpc_id
  subnet_cidr             = var.public_subnet_cidr
  availability_zone       = local.availability_zones[0]
  subnet_name             = var.public_subnet_name
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags                    = var.common_tags
}

# Internet Gateway Module
module "internet_gateway" {
  source = "../modules/networking/internet_gateway"
  
  vpc_id   = module.vpc.vpc_id
  igw_name = var.igw_name
  tags     = var.common_tags
}

# Route Tables Module
module "route_tables" {
  source = "../modules/networking/route_tables"
  
  vpc_id               = module.vpc.vpc_id
  internet_gateway_id  = module.internet_gateway.igw_id
  subnet_ids           = [module.public_subnet.subnet_id]
  route_table_name     = var.route_table_name
  tags                 = var.common_tags
}

# Store outputs in SSM for other stages to use
resource "aws_ssm_parameter" "vpc_id" {
  name  = "/terraform/stage1/vpc_id"
  type  = "String"
  value = module.vpc.vpc_id
  tags  = var.common_tags
}

resource "aws_ssm_parameter" "public_subnet_id" {
  name  = "/terraform/stage1/public_subnet_id"
  type  = "String"
  value = module.public_subnet.subnet_id
  tags  = var.common_tags
}

resource "aws_ssm_parameter" "internet_gateway_id" {
  name  = "/terraform/stage1/internet_gateway_id"
  type  = "String"
  value = module.internet_gateway.igw_id
  tags  = var.common_tags
}