# Stage 2: Networking Services
# Elastic IP and other networking services

# Get VPC ID and subnet ID from Stage 1
data "aws_ssm_parameter" "vpc_id" {
  name = "/terraform/stage1/vpc_id"
}

data "aws_ssm_parameter" "public_subnet_id" {
  name = "/terraform/stage1/public_subnet_id"
}

data "aws_ssm_parameter" "internet_gateway_id" {
  name = "/terraform/stage1/internet_gateway_id"
}

locals {
  vpc_id               = data.aws_ssm_parameter.vpc_id.value
  public_subnet_id     = data.aws_ssm_parameter.public_subnet_id.value
  internet_gateway_id  = data.aws_ssm_parameter.internet_gateway_id.value
}

# Elastic IP Module - Create EIP without instance association initially
module "elastic_ip" {
  source = "../modules/networking_services/elastic_public_ip"
  
  # Don't associate with instance during initial deployment
  instance_id           = null
  eip_name              = var.eip_name
  internet_gateway_id   = local.internet_gateway_id
  tags                  = var.common_tags
}

# Store EIP allocation ID for Stage 4 to use
resource "aws_ssm_parameter" "eip_allocation_id" {
  name  = "/terraform/stage2/eip_allocation_id"
  type  = "String"
  value = module.elastic_ip.eip_allocation_id
  tags  = var.common_tags
}

resource "aws_ssm_parameter" "eip_public_ip" {
  name  = "/terraform/stage2/eip_public_ip"
  type  = "String"
  value = module.elastic_ip.eip_public_ip
  tags  = var.common_tags
}