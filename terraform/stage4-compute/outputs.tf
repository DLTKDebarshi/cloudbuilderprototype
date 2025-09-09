# Stage 4 Compute Outputs

output "windows_instance_id" {
  description = "Windows server instance ID"
  value       = module.windows_server.instance_id
}

output "windows_public_ip" {
  description = "Windows server public IP (Elastic IP)"
  value       = data.aws_eip.windows_eip.public_ip
}

output "windows_private_ip" {
  description = "Windows server private IP"
  value       = module.windows_server.instance_private_ip
}

output "key_pair_name" {
  description = "Key pair name"
  value       = module.key_pair.key_name
}

output "eip_association_id" {
  description = "Elastic IP association ID"
  value       = aws_eip_association.windows_eip_assoc.id
}