# NAT Gateway Module - Following your GitHub repository style

resource "aws_nat_gateway" "this" {
  allocation_id = var.allocation_id
  subnet_id     = var.subnet_id

  tags = merge(var.tags, {
    Name = var.name
  })
}
