# Terraform Variables File

aws_region   = "us-east-1"
environment  = "dev"
project_name = "cloudbuilder-prototype"

terraform_state_bucket = "your-terraform-state-bucket"

common_tags = {
  Environment = "dev"
  Project     = "cloudbuilder-prototype"
  Owner       = "DevOps Team"
}

vpc_cidr             = "10.0.0.0/16"
vpc_name             = "cloudbuilder-vpc"
enable_dns_hostnames = true
enable_dns_support   = true

public_subnet_cidr      = "10.0.1.0/24"
public_subnet_name      = "cloudbuilder-public-subnet"
map_public_ip_on_launch = true

igw_name         = "cloudbuilder-igw"
route_table_name = "cloudbuilder-public-rt"

security_group_name        = "cloudbuilder-windows-sg"
security_group_description = "Security group for Windows web server"

key_pair_name = "cloudbuilder-keypair"
# IMPORTANT: Replace the value below with your real single-line OpenSSH RSA public key
public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQChd7FABIkmRgV+/dq6CL/ttq2afm0QDePKby8vCDFp5ryEmTrq+wvKbU1hesro8XyUYt99+x27LAJ0N8MU4fEqmLnEVwWs/8hbagjyWDNxzNnXVe97gMPICUlEw8pZ03hNTHjCfbkvgaV/iMgdOIHtk2Fyz3d1hFYHzdprvouu1P/xDMfkiO/uMS636hoirkmT6xxykwp+isBnEK+4KGdFEhTUs6TyAXiL22dqwKWoJ+8Unkc4K9iYVHjcz58hA0nYmBb0mHGScvsWCJpWLr0jsdyHTGZth4tVMuskz6iK4bvl1gEzd9JkLCgeLt06bPKtzaQFKc8Z/HkPG+L749ad cloudbuilder@prototype"

windows_instance_type = "t3.medium"
windows_instance_name = "cloudbuilder-windows"

eip_name = "cloudbuilder-eip"

windows_user_data = <<-EOF
<powershell>
Enable-PSRemoting -Force
winrm quickconfig -q
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="512"}'
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install dotnetfx -y
</powershell>
EOF
