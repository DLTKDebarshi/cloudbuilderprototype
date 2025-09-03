# Cloud Builder Prototype - Setup Instructions

## Quick Start Guide

### 1. Prerequisites
- AWS CLI configured with credentials
- Terraform >= 1.0
- Ansible >= 6.0.0
- Python 3.8+
- .NET 6.0 SDK (for local development)

### 2. Initial Setup
```bash
# Clone the repository
git clone <repository-url>
cd cloudbuilderprototype

# Generate all artifacts
python3 generate_artifacts.py

# Edit terraform variables
vim terraform/terraform.tfvars
```

### 3. Required Configuration Updates

Edit `terraform/terraform.tfvars`:
```hcl
# Replace these values
terraform_state_bucket = "your-actual-terraform-state-bucket"
public_key = "your-actual-ssh-public-key"
aws_region = "your-preferred-region"
```

### 4. Deploy Infrastructure
```bash
# Option 1: Use the deployment script
./scripts/deploy.sh

# Option 2: Manual deployment
cd terraform
terraform init
terraform plan
terraform apply
```

### 5. Configure GitHub Actions (Optional)

Set these repository secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `WINDOWS_PASSWORD`
- `WINDOWS_HOST`
- `WINDOWS_INSTANCE_ID`
- `PRIVATE_KEY_FILE`

Copy workflows to .github/workflows:
```bash
cp pipelines/github_actions/*.yml .github/workflows/
```

### 6. Deploy .NET Application
```bash
# Configure Windows server first
ansible-playbook playbooks/windows/iis_configuration/setup_iis.yml \
    -e windows_password="<password>" \
    -e ansible_host="<instance-ip>"

# Deploy the application (done by CI/CD or manually)
```

## Architecture Summary

### Infrastructure Components (Terraform)
- **VPC** with public subnet and internet gateway
- **EC2 Windows Server** instance with security groups
- **Elastic IP** for static addressing
- **Route53** for DNS management
- **Load Balancer** for high availability

### Automation (Ansible)
- **IIS Configuration** - Web server setup
- **System Management** - Updates and services
- **File Management** - Directory structure
- **Network Security** - Firewall rules
- **AWS Integration** - Password retrieval

### CI/CD Pipelines (GitHub Actions)
- **Infrastructure Deployment** - Terraform automation
- **Server Configuration** - Ansible automation
- **Application Deployment** - .NET app deployment

### Sample Application
- **.NET 6.0 MVC** Hello World application
- **Bootstrap UI** with modern styling
- **Health Check** endpoint
- **Responsive design** with proper styling

## Troubleshooting

### Common Issues
1. **Terraform state bucket**: Create S3 bucket manually first
2. **SSH key**: Generate and add public key to terraform.tfvars
3. **Windows password**: Wait 10-15 minutes after instance creation
4. **WinRM connectivity**: Ensure security groups allow port 5985

### Useful Commands
```bash
# Check Terraform status
terraform state list
terraform output

# Test Ansible connectivity
ansible windows -m win_ping

# Check application health
curl http://<instance-ip>/Home/Health
```

## Next Steps
1. Customize the infrastructure modules for your needs
2. Add monitoring and logging
3. Implement backup strategies
4. Set up proper SSL/TLS certificates
5. Configure domain names and DNS