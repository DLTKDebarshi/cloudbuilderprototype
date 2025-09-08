#!/usr/bin/env python3
"""
Cloud Builder Prototype - Artifact Generator

This script reads the requirements.json file and generates Terraform, Ansible, and 
GitHub Actions artifacts based on the specified requirements.
"""

import json
import os
import sys
from pathlib import Path
from typing import Dict, List, Any


class ArtifactGenerator:
    def __init__(self, requirements_file: str):
        """Initialize the generator with requirements file."""
        self.requirements_file = requirements_file
        self.requirements = self._load_requirements()
        self.base_dir = Path.cwd()
        
    def _load_requirements(self) -> Dict[str, Any]:
        """Load requirements from JSON file."""
        try:
            with open(self.requirements_file, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            print(f"Error: Requirements file '{self.requirements_file}' not found.")
            sys.exit(1)
        except json.JSONDecodeError as e:
            print(f"Error: Invalid JSON in requirements file: {e}")
            sys.exit(1)

    def generate_terraform_artifacts(self):
        """Generate Terraform configuration files."""
        print("Generating Terraform artifacts...")
        
        # Create terraform directory structure
        terraform_dir = self.base_dir / "terraform"
        terraform_dir.mkdir(exist_ok=True)
        
        # Generate provider.tf
        self._generate_provider_tf(terraform_dir)
        
        # Generate main.tf (calling modules)
        self._generate_main_tf(terraform_dir)
        
        # Generate variables.tf
        self._generate_variables_tf(terraform_dir)
        
        # Generate terraform.tfvars
        self._generate_terraform_tfvars(terraform_dir)
        
        print("✅ Terraform artifacts generated successfully!")

    def _generate_provider_tf(self, terraform_dir: Path):
        """Generate provider configuration."""
        provider_content = '''terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket = var.terraform_state_bucket
    key    = "terraform.tfstate"
    region = var.aws_region
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment   = var.environment
      Project       = var.project_name
      ManagedBy     = "Terraform"
      CreatedBy     = "CloudBuilderPrototype"
    }
  }
}
'''
        with open(terraform_dir / "provider.tf", 'w') as f:
            f.write(provider_content)

    def _generate_main_tf(self, terraform_dir: Path):
        """Generate main Terraform configuration calling modules."""
        modules = self.requirements.get("terraformModules", {})
        
        content = "# Main Terraform configuration\n\n"
        
        # Data sources
        content += '''# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

locals {
  availability_zones = data.aws_availability_zones.available.names
  account_id        = data.aws_caller_identity.current.account_id
}

'''

        # Generate module calls for networking
        if "networking" in modules:
            networking = modules["networking"]
            
            if "vpc" in networking:
                content += '''# VPC Module
module "vpc" {
  source = "./modules/networking/vpc"
  
  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags                 = var.common_tags
}

'''
            
            if "publicSubnet" in networking:
                content += '''# Public Subnet Module
module "public_subnet" {
  source = "./modules/networking/public_subnet"
  
  vpc_id                  = module.vpc.vpc_id
  subnet_cidr             = var.public_subnet_cidr
  availability_zone       = local.availability_zones[0]
  subnet_name             = var.public_subnet_name
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags                    = var.common_tags
}

'''
            
            if "internetGateway" in networking:
                content += '''# Internet Gateway Module
module "internet_gateway" {
  source = "./modules/networking/internet_gateway"
  
  vpc_id   = module.vpc.vpc_id
  igw_name = var.igw_name
  tags     = var.common_tags
}

'''
            
            if "routeTables" in networking:
                content += '''# Route Tables Module
module "route_tables" {
  source = "./modules/networking/route_tables"
  
  vpc_id               = module.vpc.vpc_id
  internet_gateway_id  = module.internet_gateway.igw_id
  subnet_ids           = [module.public_subnet.subnet_id]
  route_table_name     = var.route_table_name
  tags                 = var.common_tags
}

'''

        # Generate module calls for security
        if "security" in modules:
            security = modules["security"]
            
            if "securityGroup" in security:
                content += '''# Security Group Module
module "security_group" {
  source = "./modules/security/security_group"
  
  security_group_name = var.security_group_name
  description         = var.security_group_description
  vpc_id              = module.vpc.vpc_id
  ingress_rules       = var.security_group_ingress_rules
  egress_rules        = var.security_group_egress_rules
  tags                = var.common_tags
}

'''

        # Generate module calls for compute
        if "compute" in modules:
            compute = modules["compute"]
            
            if "keyPair" in compute:
                content += '''# Key Pair Module
module "key_pair" {
  source = "./modules/compute/key_pair"
  
  key_name   = var.key_pair_name
  public_key = var.public_key
  tags       = var.common_tags
}

'''
            
            if "windowsServer" in compute:
                content += '''# Windows Server Module
module "windows_server" {
  source = "./modules/compute/windows_server"
  
  instance_type          = var.windows_instance_type
  key_name               = module.key_pair.key_name
  security_group_ids     = [module.security_group.security_group_id]
  subnet_id              = module.public_subnet.subnet_id
  instance_name          = var.windows_instance_name
  user_data              = var.windows_user_data
  tags                   = var.common_tags
}

'''

        # Generate module calls for networking services
        if "networking_services" in modules:
            networking_services = modules["networking_services"]
            
            if "elasticPublicIp" in networking_services:
                content += '''# Elastic IP Module
module "elastic_ip" {
  source = "./modules/networking_services/elastic_public_ip"
  
  instance_id           = module.windows_server.instance_id
  eip_name              = var.eip_name
  internet_gateway_id   = module.internet_gateway.igw_id
  tags                  = var.common_tags
}

'''

        # Outputs
        content += '''# Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = module.public_subnet.subnet_id
}

output "windows_instance_id" {
  description = "Windows server instance ID"
  value       = module.windows_server.instance_id
}

output "windows_public_ip" {
  description = "Windows server public IP"
  value       = module.windows_server.instance_public_ip
}

output "windows_private_ip" {
  description = "Windows server private IP"
  value       = module.windows_server.instance_private_ip
}

output "security_group_id" {
  description = "Security group ID"
  value       = module.security_group.security_group_id
}
'''

        with open(terraform_dir / "main.tf", 'w') as f:
            f.write(content)

    def _generate_variables_tf(self, terraform_dir: Path):
        """Generate variables configuration."""
        variables_content = '''# Variables for Terraform configuration

# General Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "cloudbuilder-prototype"
}

variable "terraform_state_bucket" {
  description = "S3 bucket for Terraform state"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "main-vpc"
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

# Subnet Variables
variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_name" {
  description = "Name of the public subnet"
  type        = string
  default     = "public-subnet"
}

variable "map_public_ip_on_launch" {
  description = "Map public IP on launch"
  type        = bool
  default     = true
}

# Internet Gateway Variables
variable "igw_name" {
  description = "Name of the Internet Gateway"
  type        = string
  default     = "main-igw"
}

# Route Table Variables
variable "route_table_name" {
  description = "Name of the route table"
  type        = string
  default     = "public-route-table"
}

# Security Group Variables
variable "security_group_name" {
  description = "Name of the security group"
  type        = string
  default     = "windows-web-sg"
}

variable "security_group_description" {
  description = "Description of the security group"
  type        = string
  default     = "Security group for Windows web server"
}

variable "security_group_ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS"
    },
    {
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "RDP"
    },
    {
      from_port   = 5985
      to_port     = 5985
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "WinRM HTTP"
    }
  ]
}

variable "security_group_egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "All outbound traffic"
    }
  ]
}

# Key Pair Variables
variable "key_pair_name" {
  description = "Name of the key pair"
  type        = string
  default     = "windows-keypair"
}

variable "public_key" {
  description = "Public key content"
  type        = string
}

# Windows Instance Variables
variable "windows_instance_type" {
  description = "Instance type for Windows server"
  type        = string
  default     = "t3.medium"
}

variable "windows_instance_name" {
  description = "Name of the Windows instance"
  type        = string
  default     = "windows-web-server"
}

variable "windows_user_data" {
  description = "User data for Windows instance"
  type        = string
  default     = ""
}

# Elastic IP Variables
variable "eip_name" {
  description = "Name of the Elastic IP"
  type        = string
  default     = "windows-eip"
}
'''
        with open(terraform_dir / "variables.tf", 'w') as f:
            f.write(variables_content)

    def _generate_terraform_tfvars(self, terraform_dir: Path):
        """Generate terraform.tfvars with default values."""
        tfvars_content = '''# Terraform Variables File

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
'''
        with open(terraform_dir / "terraform.tfvars", 'w') as f:
            f.write(tfvars_content)

    def generate_github_actions_artifacts(self):
        """Generate GitHub Actions workflow files."""
        print("Generating GitHub Actions artifacts...")
        
        # Create .github/workflows directory
        workflows_dir = self.base_dir / ".github" / "workflows"
        workflows_dir.mkdir(parents=True, exist_ok=True)
        
        # Copy pipeline files to workflows directory
        pipelines_dir = self.base_dir / "pipelines" / "github_actions"
        if pipelines_dir.exists():
            import shutil
            for workflow_file in pipelines_dir.glob("*.yml"):
                shutil.copy2(workflow_file, workflows_dir)
        
        print("✅ GitHub Actions artifacts generated successfully!")

    def generate_deployment_scripts(self):
        """Generate deployment scripts."""
        print("Generating deployment scripts...")
        
        scripts_dir = self.base_dir / "scripts"
        scripts_dir.mkdir(exist_ok=True)
        
        # Generate deployment script
        deploy_script = '''#!/bin/bash
# Deployment script for Cloud Builder Prototype

set -e

echo "🚀 Starting deployment..."

# Check if required tools are installed
command -v terraform >/dev/null 2>&1 || { echo "❌ Terraform is required but not installed."; exit 1; }
command -v ansible >/dev/null 2>&1 || { echo "❌ Ansible is required but not installed."; exit 1; }

# Set variables
TERRAFORM_DIR="./terraform"
PLAYBOOKS_DIR="./playbooks"

echo "📋 Validating Terraform configuration..."
cd $TERRAFORM_DIR
terraform fmt -check=true
terraform validate

echo "🏗️  Initializing Terraform..."
terraform init

echo "📊 Planning Terraform deployment..."
terraform plan -out=tfplan

echo "🚀 Applying Terraform configuration..."
terraform apply tfplan

echo "📤 Getting Terraform outputs..."
WINDOWS_PUBLIC_IP=$(terraform output -raw windows_public_ip)
WINDOWS_INSTANCE_ID=$(terraform output -raw windows_instance_id)

echo "Windows Instance Public IP: $WINDOWS_PUBLIC_IP"
echo "Windows Instance ID: $WINDOWS_INSTANCE_ID"

# Wait for instance to be ready
echo "⏳ Waiting for Windows instance to be ready..."
sleep 300

cd ..

echo "🔧 Running Ansible playbooks..."
ansible-playbook $PLAYBOOKS_DIR/windows/iis_configuration/setup_iis.yml \\
    -e windows_password="$WINDOWS_PASSWORD" \\
    -e ansible_host="$WINDOWS_PUBLIC_IP"

echo "✅ Deployment completed successfully!"
echo "🌐 Access your Windows server at: $WINDOWS_PUBLIC_IP"
'''
        
        with open(scripts_dir / "deploy.sh", 'w') as f:
            f.write(deploy_script)
        
        # Make script executable
        os.chmod(scripts_dir / "deploy.sh", 0o755)
        
        print("✅ Deployment scripts generated successfully!")

    def generate_readme(self):
        """Generate comprehensive README file."""
        print("Generating README documentation...")
        
        readme_content = '''# Cloud Builder Prototype

A comprehensive infrastructure-as-code solution for deploying Windows-based web applications on AWS using Terraform, Ansible, and GitHub Actions.

## 🏗️ Architecture

This project provides a modular infrastructure setup including:

### 🔧 Infrastructure Components (Terraform)
- **Networking**: VPC, Public Subnets, Internet Gateway, Route Tables
- **Compute**: EC2 instances (Windows Server), Key Pairs
- **Security**: Security Groups with proper firewall rules
- **Networking Services**: Elastic IPs, Route53 DNS, Load Balancers

### ⚙️ Configuration Management (Ansible)
- **IIS Configuration**: Web server setup and application pool management
- **System Management**: Windows updates, services, and basic hardening
- **File Management**: Directory structure and permission management
- **Networking**: Firewall configuration and connectivity testing
- **AWS Integration**: Instance password retrieval and AWS CLI setup

### 🚀 CI/CD Pipelines (GitHub Actions)
- **Terraform Deployment**: Infrastructure provisioning and management
- **Ansible Configuration**: Automated server configuration
- **Application Deployment**: .NET application deployment pipeline

## 📁 Directory Structure

```
├── terraform/                 # Infrastructure as Code
│   ├── modules/               # Reusable Terraform modules
│   │   ├── networking/        # VPC, subnets, gateways
│   │   ├── compute/          # EC2 instances, key pairs
│   │   ├── security/         # Security groups
│   │   └── networking_services/ # EIP, Route53, Load Balancers
│   ├── main.tf               # Main configuration
│   ├── variables.tf          # Variable definitions
│   ├── provider.tf           # Provider configuration
│   └── terraform.tfvars      # Variable values
├── playbooks/                # Ansible automation
│   └── windows/              # Windows-specific playbooks
│       ├── iis_configuration/
│       ├── system_management/
│       ├── file_management/
│       ├── networking/
│       └── aws_integration/
├── pipelines/                # CI/CD workflows
│   └── github_actions/       # GitHub Actions workflows
├── app/                      # Sample applications
│   └── dotnet-hello-world/   # Sample .NET application
├── scripts/                  # Deployment scripts
└── requirements.json         # Infrastructure requirements
```

## 🚀 Quick Start

### Prerequisites
- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- Ansible >= 6.0.0
- Python 3.8+

### 1. Generate Artifacts
```bash
# Generate all infrastructure artifacts from requirements
python3 generate_artifacts.py
```

### 2. Configure Variables
Edit `terraform/terraform.tfvars` with your specific values:
```hcl
# Replace with your values
terraform_state_bucket = "your-terraform-state-bucket-name"
public_key = "your-ssh-public-key-content"
aws_region = "your-preferred-region"
```

### 3. Deploy Infrastructure
```bash
# Using the deployment script
chmod +x scripts/deploy.sh
./scripts/deploy.sh

# Or manually
cd terraform
terraform init
terraform plan
terraform apply
```

### 4. Configure Windows Server
```bash
# Get the Windows password first
aws ec2 get-password-data --instance-id <instance-id> --priv-launch-key <private-key-file>

# Run Ansible configuration
ansible-playbook playbooks/windows/iis_configuration/setup_iis.yml \\
    -e windows_password="<retrieved-password>" \\
    -e ansible_host="<instance-public-ip>"
```

## 🔧 Customization

### Adding New Terraform Modules
1. Create module directory under `terraform/modules/`
2. Update `requirements.json` to include the new module
3. Run `python3 generate_artifacts.py` to regenerate configurations

### Adding New Ansible Playbooks
1. Create playbook under `playbooks/windows/`
2. Update `requirements.json` ansible section
3. Update GitHub Actions workflow to include new playbook

### Modifying CI/CD Pipelines
1. Edit workflow files in `pipelines/github_actions/`
2. Copy to `.github/workflows/` for activation
3. Configure repository secrets for AWS credentials

## 🔐 Security Considerations

### Required Secrets (GitHub Actions)
- `AWS_ACCESS_KEY_ID`: AWS access key
- `AWS_SECRET_ACCESS_KEY`: AWS secret key
- `WINDOWS_PASSWORD`: Windows administrator password
- `WINDOWS_HOST`: Windows instance public IP
- `WINDOWS_INSTANCE_ID`: EC2 instance ID
- `PRIVATE_KEY_FILE`: Private key for Windows password decryption

### Security Groups
The default configuration includes:
- HTTP (80) and HTTPS (443) for web traffic
- RDP (3389) for remote management
- WinRM (5985) for Ansible automation

**⚠️ Important**: Restrict source IP ranges in production environments.

## 📊 Monitoring and Troubleshooting

### Terraform
```bash
# Check resource status
terraform state list
terraform show

# Debug mode
TF_LOG=DEBUG terraform apply
```

### Ansible
```bash
# Test connectivity
ansible windows -m win_ping

# Verbose mode
ansible-playbook playbook.yml -vvv
```

### Windows Instance
```bash
# Check WinRM connectivity
nc -zv <instance-ip> 5985

# Access via RDP
rdesktop <instance-ip>:3389
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Update documentation
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:
1. Check the troubleshooting section above
2. Review AWS CloudFormation events
3. Check GitHub Actions logs
4. Open an issue with detailed error information

---

Built with ❤️ for modern cloud infrastructure automation.
'''
        
        with open(self.base_dir / "README.md", 'w') as f:
            f.write(readme_content)
        
        print("✅ README documentation generated successfully!")

    def run(self):
        """Run the artifact generation process."""
        print("🏗️  Cloud Builder Prototype - Artifact Generator")
        print("=" * 50)
        
        try:
            self.generate_terraform_artifacts()
            self.generate_github_actions_artifacts()
            self.generate_deployment_scripts()
            self.generate_readme()
            
            print("\n🎉 All artifacts generated successfully!")
            print("\nNext steps:")
            print("1. Edit terraform/terraform.tfvars with your specific values")
            print("2. Run ./scripts/deploy.sh to deploy infrastructure")
            print("3. Configure GitHub repository secrets for CI/CD")
            print("4. Push to repository to trigger automated deployments")
            
        except Exception as e:
            print(f"❌ Error generating artifacts: {e}")
            sys.exit(1)


def main():
    """Main entry point."""
    requirements_file = "requirements.json"
    
    if len(sys.argv) > 1:
        requirements_file = sys.argv[1]
    
    generator = ArtifactGenerator(requirements_file)
    generator.run()


if __name__ == "__main__":
    main()