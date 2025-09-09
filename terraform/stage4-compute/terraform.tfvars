# Stage 4 Compute Configuration - Following your GitHub repository style

instances = {
  web_server = {
    instance_type      = "t3.medium"
    subnet_key         = "public_subnet_1a"
    security_group_key = "web_sg"
    associate_eip      = false
    tags = {
      Name = "cloudbuilder-web-server-001"
      Role = "web-server"
      OS   = "Windows"
    }
  }

  app_server = {
    instance_type      = "t3.large"
    subnet_key         = "public_subnet_1a"
    security_group_key = "app_sg"
    associate_eip      = false
    tags = {
      Name = "cloudbuilder-app-server-001"
      Role = "app-server"
      OS   = "Windows"
    }
  }
}
