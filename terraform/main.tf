# Main Terraform configuration

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

locals {
  availability_zones = data.aws_availability_zones.available.names
  account_id         = data.aws_caller_identity.current.account_id
}

# VPC Module
module "vpc" {
  source = "./modules/networking/vpc"

  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags                 = var.common_tags
}

# Public Subnet Module
module "public_subnet" {
  source = "./modules/networking/public_subnet"

  vpc_id                  = module.vpc.vpc_id
  subnet_cidr             = var.public_subnet_cidr
  availability_zone       = local.availability_zones[0]
  subnet_name             = var.public_subnet_name
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags                    = var.common_tags
}

# Internet Gateway Module
module "internet_gateway" {
  source = "./modules/networking/internet_gateway"

  vpc_id   = module.vpc.vpc_id
  igw_name = var.igw_name
  tags     = var.common_tags
}

# Route Tables Module
module "route_tables" {
  source = "./modules/networking/route_tables"

  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.internet_gateway.igw_id
  subnet_ids          = [module.public_subnet.subnet_id]
  route_table_name    = var.route_table_name
  tags                = var.common_tags
}

# Security Group Module
module "security_group" {
  source = "./modules/security/security_group"

  security_group_name = var.security_group_name
  description         = var.security_group_description
  vpc_id              = module.vpc.vpc_id
  ingress_rules       = var.security_group_ingress_rules
  egress_rules        = var.security_group_egress_rules
  tags                = var.common_tags
}

# Key Pair Module
module "key_pair" {
  source = "./modules/compute/key_pair"

  key_name   = var.key_pair_name
  public_key = var.public_key
  tags       = var.common_tags
}

# Windows Server Module
module "windows_server" {
  source = "./modules/compute/windows_server"

  instance_type      = var.windows_instance_type
  key_name           = module.key_pair.key_name
  security_group_ids = [module.security_group.security_group_id]
  subnet_id          = module.public_subnet.subnet_id
  instance_name      = var.windows_instance_name
  user_data          = var.windows_user_data
  tags               = var.common_tags
}

# Elastic IP Module
module "elastic_ip" {
  source = "./modules/networking_services/elastic_public_ip"

  instance_id         = module.windows_server.instance_id
  eip_name            = var.eip_name
  internet_gateway_id = module.internet_gateway.igw_id
  tags                = var.common_tags
}

# Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = module.public_subnet.subnet_id
}

output "windows_instance_id" {
  description = "Windows server instance ID"
  value       = module.windows_server.instance_id
}

output "windows_public_ip" {
  description = "Windows server public IP"
  value       = module.windows_server.instance_public_ip
}

output "windows_private_ip" {
  description = "Windows server private IP"
  value       = module.windows_server.instance_private_ip
}

output "security_group_id" {
  description = "Security group ID"
  value       = module.security_group.security_group_id
}
