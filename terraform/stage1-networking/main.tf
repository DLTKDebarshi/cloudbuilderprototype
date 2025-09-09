# Stage 1: Networking Infrastructure - Following your GitHub repository style

# Module calls using for_each pattern with try() function
module "vpc" {
  source   = "../modules/vpc"
  for_each = try(var.vpcs, {})

  name                 = each.key
  cidr_block           = each.value.cidr_block
  enable_dns_hostnames = try(each.value.enable_dns_hostnames, true)
  enable_dns_support   = try(each.value.enable_dns_support, true)
  tags = merge(try(each.value.tags, {}), {
    DeployedBy = "Debarshi From IAC team"
  })
}

module "internet_gateway" {
  source   = "../modules/internet_gateway"
  for_each = try(var.internet_gateways, {})

  name   = each.key
  vpc_id = module.vpc[each.value.vpc_key].id
  tags = merge(try(each.value.tags, {}), {
    DeployedBy = "Debarshi From IAC team"
  })
}

module "subnets" {
  source   = "../modules/subnet"
  for_each = try(var.subnets, {})

  name                    = each.key
  vpc_id                  = module.vpc[each.value.vpc_key].id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = try(each.value.map_public_ip_on_launch, false)
  tags = merge(try(each.value.tags, {}), {
    DeployedBy = "Debarshi From IAC team"
  })
}

module "route_tables" {
  source   = "../modules/route_table"
  for_each = try(var.route_tables, {})

  name   = each.key
  vpc_id = module.vpc[each.value.vpc_key].id
  routes = try(each.value.routes, [])
  tags = merge(try(each.value.tags, {}), {
    DeployedBy = "Debarshi From IAC team"
  })

  depends_on = [module.internet_gateway]
}

# Store outputs in SSM for other stages to use
resource "aws_ssm_parameter" "vpc_outputs" {
  for_each = module.vpc

  name  = "/terraform/stage1/vpc/${each.key}/id"
  type  = "String"
  value = each.value.id
  tags = {
    DeployedBy = "Debarshi From IAC team"
    Stage      = "networking"
  }
}

resource "aws_ssm_parameter" "subnet_outputs" {
  for_each = module.subnets

  name  = "/terraform/stage1/subnet/${each.key}/id"
  type  = "String"
  value = each.value.id
  tags = {
    DeployedBy = "Debarshi From IAC team"
    Stage      = "networking"
  }
}

resource "aws_ssm_parameter" "internet_gateway_outputs" {
  for_each = module.internet_gateway

  name  = "/terraform/stage1/igw/${each.key}/id"
  type  = "String"
  value = each.value.id
  tags = {
    DeployedBy = "Debarshi From IAC team"
    Stage      = "networking"
  }
}