# Stage 2 Networking Services Configuration - Following your GitHub repository style

elastic_ips = {
  nat_eip_1a = {
    tags = {
      Name = "cloudbuilder-nat-eip-1a"
    }
  }
}

nat_gateways = {
  nat_gw_1a = {
    subnet_key = "public_subnet_1a"
    eip_key    = "nat_eip_1a"
    tags = {
      Name = "cloudbuilder-nat-gateway-1a"
    }
  }
}
