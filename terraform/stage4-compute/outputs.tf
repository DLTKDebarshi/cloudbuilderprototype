# Stage 4 Compute Outputs - Following your GitHub repository style

output "instance_ids" {
  description = "Instance IDs"
  value       = { for k, v in module.instance : k => v.id }
}

output "instance_public_ips" {
  description = "Instance public IPs"
  value       = { for k, v in module.instance : k => v.public_ip }
}

output "instance_private_ips" {
  description = "Instance private IPs"
  value       = { for k, v in module.instance : k => v.private_ip }
}