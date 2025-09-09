# Stage 4 Compute Outputs

output "instance_ids" {
  description = "Map of instance IDs"
  value = {
    for key, instance in module.compute_instances : key => instance.instance_id
  }
}

output "instance_public_ips" {
  description = "Map of instance public IPs (Elastic IP)"
  value = {
    for key, instance in module.compute_instances : key => data.aws_eip.instance_eip.public_ip
  }
}

output "instance_private_ips" {
  description = "Map of instance private IPs"
  value = {
    for key, instance in module.compute_instances : key => instance.instance_private_ip
  }
}

output "eip_association_ids" {
  description = "Map of Elastic IP association IDs"
  value = {
    for key, assoc in aws_eip_association.instance_eip_assoc : key => assoc.id
  }
}