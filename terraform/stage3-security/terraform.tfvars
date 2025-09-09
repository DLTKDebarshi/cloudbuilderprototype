# Stage 3 Security Configuration - Following your GitHub repository style

security_groups = {
  web_sg = {
    vpc_key     = "main_vpc"
    description = "Security group for web servers"

    ingress_rules = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP access"
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTPS access"
      },
      {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "RDP access"
      },
      {
        from_port   = 5985
        to_port     = 5986
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "WinRM access"
      }
    ]

    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "All outbound traffic"
      }
    ]

    tags = {
      Name = "cloudbuilder-web-sg"
      Type = "Web"
    }
  }

  app_sg = {
    vpc_key     = "main_vpc"
    description = "Security group for application servers"

    ingress_rules = [
      {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
        description = "Application port"
      },
      {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "RDP access"
      },
      {
        from_port   = 5985
        to_port     = 5986
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "WinRM access"
      }
    ]

    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "All outbound traffic"
      }
    ]

    tags = {
      Name = "cloudbuilder-app-sg"
      Type = "Application"
    }
  }
}
