resource "aws_internet_gateway" "main" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = var.igw_name
  })
}

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}