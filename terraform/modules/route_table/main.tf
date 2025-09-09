# Route Table Module - Following your GitHub repository style

# Data sources to look up resources dynamically
data "aws_internet_gateway" "igw" {
  for_each = {
    for route in var.routes : "${route.cidr_block}-${route.gateway_key}" => route
    if route.gateway_id == "igw"
  }
  
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}

resource "aws_route_table" "this" {
  vpc_id = var.vpc_id

  dynamic "route" {
    for_each = var.routes
    content {
      cidr_block = route.value.cidr_block
      gateway_id = route.value.gateway_id == "igw" ? data.aws_internet_gateway.igw["${route.value.cidr_block}-${route.value.gateway_key}"].id : route.value.gateway_id
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}
