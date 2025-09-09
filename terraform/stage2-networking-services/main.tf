# Stage 2: Networking Services - Following your GitHub repository style

# Data sources to get outputs from stage1
data "aws_ssm_parameter" "vpc_outputs" {
  for_each = toset(["main_vpc"])
  name     = "/terraform/stage1/vpc/${each.key}/id"
}

data "aws_ssm_parameter" "subnet_outputs" {
  for_each = toset(["public_subnet_1a", "public_subnet_1b"])
  name     = "/terraform/stage1/subnet/${each.key}/id"
}

# Module calls using for_each pattern with try() function
module "elastic_ip" {
  source   = "../modules/elastic_ip"
  for_each = try(var.elastic_ips, {})

  name = each.key
  tags = merge(try(each.value.tags, {}), {
    DeployedBy = "Debarshi From IAC team"
  })
}

module "nat_gateway" {
  source   = "../modules/nat_gateway"
  for_each = try(var.nat_gateways, {})

  name          = each.key
  subnet_id     = data.aws_ssm_parameter.subnet_outputs[each.value.subnet_key].value
  allocation_id = module.elastic_ip[each.value.eip_key].allocation_id
  tags = merge(try(each.value.tags, {}), {
    DeployedBy = "Debarshi From IAC team"
  })
}

# Store outputs in SSM for other stages to use
resource "aws_ssm_parameter" "elastic_ip_outputs" {
  for_each = module.elastic_ip

  name  = "/terraform/stage2/eip/${each.key}/allocation_id"
  type  = "String"
  value = each.value.allocation_id
  tags = {
    DeployedBy = "Debarshi From IAC team"
    Stage      = "networking-services"
  }
}

resource "aws_ssm_parameter" "nat_gateway_outputs" {
  for_each = module.nat_gateway

  name  = "/terraform/stage2/nat/${each.key}/id"
  type  = "String"
  value = each.value.id
  tags = {
    DeployedBy = "Debarshi From IAC team"
    Stage      = "networking-services"
  }
}