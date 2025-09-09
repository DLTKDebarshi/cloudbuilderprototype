# Stage 3: Security Infrastructure
# Security Groups

# Get VPC ID from Stage 1
data "aws_ssm_parameter" "vpc_id" {
  name = "/terraform/stage1/vpc_id"
}

locals {
  vpc_id = data.aws_ssm_parameter.vpc_id.value
}

# Security Group Module
module "security_group" {
  source = "../modules/security/security_group"
  
  security_group_name = var.security_group_name
  description         = var.security_group_description
  vpc_id              = local.vpc_id
  ingress_rules       = var.security_group_ingress_rules
  egress_rules        = var.security_group_egress_rules
  tags                = var.common_tags
}

# Store security group ID for Stage 4 to use
resource "aws_ssm_parameter" "security_group_id" {
  name  = "/terraform/stage3/security_group_id"
  type  = "String"
  value = module.security_group.security_group_id
  tags  = var.common_tags
}