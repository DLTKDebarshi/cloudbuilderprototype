# Stage 2 Networking Services Outputs

output "eip_allocation_id" {
  description = "Elastic IP allocation ID"
  value       = module.elastic_ip.eip_allocation_id
}

output "eip_public_ip" {
  description = "Elastic IP public IP address"
  value       = module.elastic_ip.eip_public_ip
}

output "eip_association_id" {
  description = "Elastic IP association ID (if associated with an instance)"
  value       = try(module.elastic_ip.eip_association_id, null)
}