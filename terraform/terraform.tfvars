# Terraform Variables File

# General Configuration
aws_region     = "us-east-1"
environment    = "dev"
project_name   = "cloudbuilder-prototype"

# Replace with your actual S3 bucket name for Terraform state
terraform_state_bucket = "your-terraform-state-bucket"

# Common tags
common_tags = {
  Environment = "dev"
  Project     = "cloudbuilder-prototype"
  Owner       = "DevOps Team"
}

# VPC Configuration
vpc_cidr               = "10.0.0.0/16"
vpc_name               = "cloudbuilder-vpc"
enable_dns_hostnames   = true
enable_dns_support     = true

# Subnet Configuration
public_subnet_cidr        = "10.0.1.0/24"
public_subnet_name        = "cloudbuilder-public-subnet"
map_public_ip_on_launch   = true

# Internet Gateway
igw_name = "cloudbuilder-igw"

# Route Table
route_table_name = "cloudbuilder-public-rt"

# Security Group
security_group_name        = "cloudbuilder-windows-sg"
security_group_description = "Security group for Windows web server"

# Key Pair - Replace with your actual public key
key_pair_name = "cloudbuilder-keypair"
public_key    = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC... # Replace with your actual public key"

# Windows Instance
windows_instance_type = "t3.medium"
windows_instance_name = "cloudbuilder-windows"

# Elastic IP
eip_name = "cloudbuilder-eip"

# User data for Windows (PowerShell script to enable WinRM)
windows_user_data = <<-EOF
<powershell>
# Enable WinRM
Enable-PSRemoting -Force
winrm quickconfig -q
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="512"}'
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'

# Configure firewall for WinRM
netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install .NET Framework and IIS prerequisites
choco install dotnetfx -y
</powershell>
EOF
