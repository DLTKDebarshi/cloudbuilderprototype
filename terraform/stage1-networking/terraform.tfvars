# Stage 1 Networking Configuration - Following your GitHub repository style

vpcs = {
  main_vpc = {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    tags = {
      Name = "cloudbuilder-main-vpc"
    }
  }
}

internet_gateways = {
  main_igw = {
    vpc_key = "main_vpc"
    tags = {
      Name = "cloudbuilder-main-igw"
    }
  }
}

subnets = {
  public_subnet_1a = {
    vpc_key                 = "main_vpc"
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "us-east-1a"
    map_public_ip_on_launch = true
    route_table_key         = "public_rt"
    tags = {
      Name = "cloudbuilder-public-subnet-1a"
      Type = "Public"
    }
  }

  public_subnet_1b = {
    vpc_key                 = "main_vpc"
    cidr_block              = "10.0.2.0/24"
    availability_zone       = "us-east-1b"
    map_public_ip_on_launch = true
    route_table_key         = "public_rt"
    tags = {
      Name = "cloudbuilder-public-subnet-1b"
      Type = "Public"
    }
  }

  private_subnet_1a = {
    vpc_key                 = "main_vpc"
    cidr_block              = "10.0.10.0/24"
    availability_zone       = "us-east-1a"
    map_public_ip_on_launch = false
    tags = {
      Name = "cloudbuilder-private-subnet-1a"
      Type = "Private"
    }
  }
}

route_tables = {
  public_rt = {
    vpc_key = "main_vpc"
    igw_key = "main_igw"
    tags = {
      Name = "cloudbuilder-public-route-table"
    }
  }
}
