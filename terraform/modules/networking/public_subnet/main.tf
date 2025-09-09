resource "aws_subnet" "public" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(var.tags, {
    Name = var.subnet_name
    Type = "Public"
  })
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = aws_subnet.public.id
}

output "subnet_cidr_block" {
  description = "The CIDR block of the subnet"
  value       = aws_subnet.public.cidr_block
}

output "availability_zone" {
  description = "The availability zone of the subnet"
  value       = aws_subnet.public.availability_zone
}