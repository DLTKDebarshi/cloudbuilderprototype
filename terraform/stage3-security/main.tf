# Stage 3: Security Infrastructure - Following your GitHub repository style

# Data sources to get outputs from stage1
data "aws_ssm_parameter" "vpc_outputs" {
  for_each = toset(["main_vpc"])
  name     = "/terraform/stage1/vpc/${each.key}/id"
}

# Module calls using for_each pattern with try() function
module "security_group" {
  source   = "../modules/security_group"
  for_each = try(var.security_groups, {})

  name        = each.key
  description = each.value.description
  vpc_id      = data.aws_ssm_parameter.vpc_outputs[each.value.vpc_key].value

  ingress_rules = try(each.value.ingress_rules, [])
  egress_rules  = try(each.value.egress_rules, [])

  tags = merge(try(each.value.tags, {}), {
    DeployedBy = "Debarshi From IAC team"
  })
}

# Store outputs in SSM for other stages to use
resource "aws_ssm_parameter" "security_group_outputs" {
  for_each = module.security_group

  name  = "/terraform/stage3/sg/${each.key}/id"
  type  = "String"
  value = each.value.id
  tags = {
    DeployedBy = "Debarshi From IAC team"
    Stage      = "security"
  }
}

# End of stage3-security configuration