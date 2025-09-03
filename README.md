# Cloud Builder Prototype

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
ansible-playbook playbooks/windows/iis_configuration/setup_iis.yml \
    -e windows_password="<retrieved-password>" \
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
