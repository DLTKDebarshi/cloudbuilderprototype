# Windows Server EC2 Instance Module
data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "windows" {
  ami                    = data.aws_ami.windows.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.security_group_ids
  subnet_id              = var.subnet_id
  
  user_data = var.user_data

  tags = merge(
    {
      Name = var.instance_name
      OS   = "Windows"
    },
    var.tags
  )
}

output "instance_id" {
  description = "The ID of the Windows instance"
  value       = aws_instance.windows.id
}

output "instance_public_ip" {
  description = "The public IP address of the Windows instance"
  value       = aws_instance.windows.public_ip
}

output "instance_private_ip" {
  description = "The private IP address of the Windows instance"
  value       = aws_instance.windows.private_ip
}

output "instance_public_dns" {
  description = "The public DNS name of the Windows instance"
  value       = aws_instance.windows.public_dns
}

output "windows_password" {
  description = "The Windows administrator password"
  value       = aws_instance.windows.password_data
  sensitive   = true
}