# Stage 3 Security Outputs - Following your GitHub repository style

output "security_group_ids" {
  description = "Security group IDs"
  value       = { for k, v in module.security_group : k => v.id }
}