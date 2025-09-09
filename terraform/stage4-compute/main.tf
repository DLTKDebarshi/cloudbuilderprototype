# Stage 4: Compute Infrastructure - Following your GitHub repository style

# Data sources to get outputs from previous stages
data "aws_ssm_parameter" "subnet_outputs" {
  for_each = toset(["public_subnet_1a"])
  name     = "/terraform/stage1/subnet/${each.key}/id"
}

data "aws_ssm_parameter" "security_group_outputs" {
  for_each = toset(["web_sg"])
  name     = "/terraform/stage3/sg/${each.key}/id"
}

data "aws_ssm_parameter" "elastic_ip_outputs" {
  for_each = toset(["nat_eip_1a"])
  name     = "/terraform/stage2/eip/${each.key}/allocation_id"
}

# Module calls using for_each pattern with try() function
module "instance" {
  source   = "../modules/instance"
  for_each = try(var.instances, {})

  name               = each.key
  instance_type      = each.value.instance_type
  subnet_id          = data.aws_ssm_parameter.subnet_outputs[each.value.subnet_key].value
  security_group_ids = [data.aws_ssm_parameter.security_group_outputs[each.value.security_group_key].value]
  
  user_data = try(each.value.user_data, templatefile("${path.module}/user_data.ps1", {
    username = var.username
    password = var.password
  }))
  
  tags = merge(try(each.value.tags, {}), {
    DeployedBy = "Debarshi From IAC team"
  })
}

# Associate Elastic IP with instances if specified
resource "aws_eip_association" "instance_eip_assoc" {
  for_each = {
    for k, v in try(var.instances, {}) : k => v
    if try(v.associate_eip, false)
  }

  instance_id   = module.instance[each.key].id
  allocation_id = local.eip_allocation_id
}

# Store instance information for other stages and validation
resource "aws_ssm_parameter" "instance_ids" {
  for_each = var.instances

  name  = "/terraform/stage4/${each.key}_instance_id"
  type  = "String"
  value = module.compute_instances[each.key].instance_id
  tags  = local.common_tags
}

# Get the actual EIP public IP after association
data "aws_eip" "instance_eip" {
  id = local.eip_allocation_id
}

resource "aws_ssm_parameter" "instance_public_ips" {
  for_each = var.instances

  name  = "/terraform/stage4/${each.key}_public_ip"
  type  = "String"
  value = data.aws_eip.instance_eip.public_ip
  tags  = local.common_tags

  depends_on = [aws_eip_association.instance_eip_assoc]
}

resource "aws_ssm_parameter" "instance_private_ips" {
  for_each = var.instances

  name  = "/terraform/stage4/${each.key}_private_ip"
  type  = "String"
  value = module.compute_instances[each.key].instance_private_ip
  tags  = local.common_tags
}