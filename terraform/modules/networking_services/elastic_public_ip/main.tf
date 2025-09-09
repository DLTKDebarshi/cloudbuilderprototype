# Elastic IP Module - Updated to support optional instance association
resource "aws_eip" "main" {
  # Don't associate with instance during creation - we'll do it separately
  domain   = "vpc"

  tags = merge(
    {
      Name = var.eip_name
    },
    var.tags
  )

  depends_on = [var.internet_gateway_id]
}

# Optional EIP association - only create if instance_id is provided
resource "aws_eip_association" "main" {
  count = var.instance_id != null ? 1 : 0
  
  instance_id   = var.instance_id
  allocation_id = aws_eip.main.allocation_id
}

output "eip_id" {
  description = "The ID of the Elastic IP"
  value       = aws_eip.main.id
}

output "eip_public_ip" {
  description = "The Elastic IP address"
  value       = aws_eip.main.public_ip
}

output "eip_allocation_id" {
  description = "The allocation ID of the Elastic IP"
  value       = aws_eip.main.allocation_id
}

output "eip_association_id" {
  description = "The association ID of the Elastic IP (if associated)"
  value       = length(aws_eip_association.main) > 0 ? aws_eip_association.main[0].id : null
}