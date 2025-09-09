# Stage 4: Compute Infrastructure
# EC2 Instances, Key Pairs

# Get required resources from previous stages
data "aws_ssm_parameter" "public_subnet_id" {
  name = "/terraform/stage1/public_subnet_id"
}

data "aws_ssm_parameter" "security_group_id" {
  name = "/terraform/stage3/security_group_id"
}

data "aws_ssm_parameter" "eip_allocation_id" {
  name = "/terraform/stage2/eip_allocation_id"
}

locals {
  public_subnet_id     = data.aws_ssm_parameter.public_subnet_id.value
  security_group_id    = data.aws_ssm_parameter.security_group_id.value
  eip_allocation_id    = data.aws_ssm_parameter.eip_allocation_id.value
}

# Key Pair Module
module "key_pair" {
  source = "../modules/compute/key_pair"
  
  key_name   = var.key_pair_name
  public_key = var.public_key
  tags       = var.common_tags
}

# Windows Server Module - Enhanced with username/password
module "windows_server" {
  source = "../modules/compute/windows_server"
  
  instance_type          = var.windows_instance_type
  key_name               = module.key_pair.key_name
  security_group_ids     = [local.security_group_id]
  subnet_id              = local.public_subnet_id
  instance_name          = var.windows_instance_name
  user_data              = templatefile("${path.module}/user_data.ps1", {
    username = var.username
    password = var.password
  })
  tags                   = var.common_tags
}

# Associate Elastic IP with the instance
resource "aws_eip_association" "windows_eip_assoc" {
  instance_id   = module.windows_server.instance_id
  allocation_id = local.eip_allocation_id
}

# Store instance information for other stages and validation
resource "aws_ssm_parameter" "windows_instance_id" {
  name  = "/terraform/stage4/windows_instance_id"
  type  = "String"
  value = module.windows_server.instance_id
  tags  = var.common_tags
}

# Get the actual EIP public IP after association
data "aws_eip" "windows_eip" {
  id = local.eip_allocation_id
}

resource "aws_ssm_parameter" "windows_public_ip" {
  name  = "/terraform/stage4/windows_public_ip"
  type  = "String"
  value = data.aws_eip.windows_eip.public_ip
  tags  = var.common_tags
  
  depends_on = [aws_eip_association.windows_eip_assoc]
}

resource "aws_ssm_parameter" "windows_private_ip" {
  name  = "/terraform/stage4/windows_private_ip"
  type  = "String"
  value = module.windows_server.instance_private_ip
  tags  = var.common_tags
}