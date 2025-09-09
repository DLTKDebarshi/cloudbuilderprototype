# Stage 1 Networking Outputs - Following your GitHub repository style

# Output VPC information
output "vpc_ids" {
  description = "VPC IDs"
  value       = { for k, v in module.vpc : k => v.id }
}

output "subnet_ids" {
  description = "Subnet IDs"
  value       = { for k, v in module.subnets : k => v.id }
}

output "internet_gateway_ids" {
  description = "Internet Gateway IDs"
  value       = { for k, v in module.internet_gateway : k => v.id }
}

output "route_table_ids" {
  description = "Route Table IDs"
  value       = { for k, v in module.route_tables : k => v.id }
}