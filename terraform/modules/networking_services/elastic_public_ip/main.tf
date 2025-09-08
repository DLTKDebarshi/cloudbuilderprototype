# Elastic IP Module
resource "aws_eip" "main" {
  instance = var.instance_id
  domain   = "vpc"

  tags = merge(
    {
      Name = var.eip_name
    },
    var.tags
  )

  depends_on = [var.internet_gateway_id]
}

output "eip_id" {
  description = "The ID of the Elastic IP"
  value       = aws_eip.main.id
}

output "public_ip" {
  description = "The Elastic IP address"
  value       = aws_eip.main.public_ip
}

output "allocation_id" {
  description = "The allocation ID of the Elastic IP"
  value       = aws_eip.main.allocation_id
}