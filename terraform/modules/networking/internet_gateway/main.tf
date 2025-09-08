# Internet Gateway Module
resource "aws_internet_gateway" "main" {
  vpc_id = var.vpc_id

  tags = merge(
    {
      Name = var.igw_name
    },
    var.tags
  )
}

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}