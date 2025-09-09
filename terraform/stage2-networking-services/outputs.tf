# Stage 2 Networking Services Outputs - Following your GitHub repository style

output "elastic_ip_allocation_ids" {
  description = "Elastic IP allocation IDs"
  value       = { for k, v in module.elastic_ip : k => v.allocation_id }
}

output "elastic_ip_public_ips" {
  description = "Elastic IP public IP addresses"
  value       = { for k, v in module.elastic_ip : k => v.public_ip }
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = { for k, v in module.nat_gateway : k => v.id }
}