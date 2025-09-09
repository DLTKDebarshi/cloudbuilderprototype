module "vpcs" {
  source     = "../../modules/vpc"
  for_each   = try(var.vpcs, {})
  vpc        = try(each.value.vpc, {})
  vpc_subnet = try(each.value.vpc_subnet, {})
}

module "internet_gateways" {
  source            = "../../modules/internet_gateway"
  internet_gateways = try(var.internet_gateways, {})
  depends_on        = [module.vpcs]
}

module "nat_gateways" {
  source       = "../../modules/nat_gateway"
  nat_gateways = try(var.nat_gateways, {})
  depends_on   = [module.vpcs, module.internet_gateways]
}

module "route_tables" {
  source       = "../../modules/route_table"
  route_tables = try(var.route_tables, {})
  depends_on   = [module.vpcs, module.nat_gateways, module.internet_gateways]
}

module "route_associations" {
  source             = "../../modules/route_table_association"
  route_associations = try(var.route_associations, {})
  depends_on         = [module.route_tables]
}

module "security_groups" {
  source          = "../../modules/security_group"
  security_groups = try(var.security_groups, {})
  depends_on      = [module.vpcs]
}

module "elastic_ips" {
  source       = "../../modules/elastic_ip"
  elastic_ips  = try(var.elastic_ips, {})
  depends_on   = [module.internet_gateways]
}

module "instances" {
  source     = "../../modules/instance"
  instances  = try(var.instances, {})
  username   = var.username
  password   = var.password
  depends_on = [module.vpcs, module.security_groups]
}
