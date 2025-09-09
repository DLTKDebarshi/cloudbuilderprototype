# Route Table Module - Following your GitHub repository style

resource "aws_route_table" "this" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = var.name
  })
}

# Routes will be managed separately or via the calling module
# This keeps the module simple following your repository pattern
