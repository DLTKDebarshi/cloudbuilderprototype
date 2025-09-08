# Key Pair Module
resource "aws_key_pair" "main" {
  key_name   = var.key_name
  public_key = var.public_key

  tags = merge(
    {
      Name = var.key_name
    },
    var.tags
  )
}

output "key_name" {
  description = "The key pair name"
  value       = aws_key_pair.main.key_name
}

output "fingerprint" {
  description = "The MD5 public key fingerprint"
  value       = aws_key_pair.main.fingerprint
}