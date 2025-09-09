# Stage 1 Networking Outputs

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = module.public_subnet.subnet_id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.internet_gateway.igw_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr_block
}

output "availability_zone" {
  description = "Availability zone used"
  value       = module.public_subnet.availability_zone
}