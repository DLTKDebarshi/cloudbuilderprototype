resource "aws_eip" "main" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name = var.eip_name
  })

  depends_on = [var.internet_gateway_id]
}

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