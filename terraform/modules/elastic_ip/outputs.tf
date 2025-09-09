output "allocation_id" {
  description = "Allocation ID of the Elastic IP"
  value       = aws_eip.this.allocation_id
}

output "public_ip" {
  description = "Public IP address"
  value       = aws_eip.this.public_ip
}
