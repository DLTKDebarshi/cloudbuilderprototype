# EC2 Instance Module
resource "aws_instance" "main" {
  ami           = var.ami_id
  instance_type = var.instance_type
  # Removed key_name dependency - using username/password authentication
  vpc_security_group_ids = var.security_group_ids
  subnet_id              = var.subnet_id

  user_data = var.user_data

  tags = merge(var.tags, {
    Name = var.instance_name
  })
}

output "instance_id" {
  description = "The ID of the instance"
  value       = aws_instance.main.id
}

output "instance_public_ip" {
  description = "The public IP address of the instance"
  value       = aws_instance.main.public_ip
}

output "instance_private_ip" {
  description = "The private IP address of the instance"
  value       = aws_instance.main.private_ip
}

output "instance_public_dns" {
  description = "The public DNS name of the instance"
  value       = aws_instance.main.public_dns
}