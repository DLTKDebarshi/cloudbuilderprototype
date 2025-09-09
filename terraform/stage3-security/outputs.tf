# Stage 3 Security Outputs

output "security_group_id" {
  description = "Security group ID"
  value       = module.security_group.security_group_id
}

output "security_group_name" {
  description = "Security group name"
  value       = module.security_group.security_group_name
}

output "security_group_arn" {
  description = "Security group ARN"
  value       = module.security_group.security_group_arn
}