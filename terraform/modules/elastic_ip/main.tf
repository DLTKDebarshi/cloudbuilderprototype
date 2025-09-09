# Elastic IP Module - Following your GitHub repository style

resource "aws_eip" "this" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name = var.name
  })
}
