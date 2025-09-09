# CloudBuilder Prototype - Combined Deployment Pipeline

This document describes how to use the new combined deployment pipeline that orchestrates infrastructure deployment, server configuration, and application deployment in a single workflow.

## Overview

The deployment pipeline has been restructured into reusable components:

### 🏗️ Infrastructure Stages
1. **Stage 1: Networking** - VPC, Subnets, Internet Gateway, Route Tables
2. **Stage 2: Networking Services** - Elastic IP and additional networking services  
3. **Stage 3: Security** - Security Groups and firewall rules
4. **Stage 4: Compute** - EC2 instances, Key Pairs, and server configuration

### 🔧 Configuration & Deployment
5. **Ansible Configuration** - Server setup, IIS installation, and prerequisites
6. **.NET Application Deployment** - Build and deploy the application to IIS
7. **Validation** - Comprehensive infrastructure and application testing

## Required GitHub Secrets

Before running the pipeline, ensure these secrets are configured in your repository:

```
AWS_ACCESS_KEY_ID          # AWS access key for infrastructure deployment
AWS_SECRET_ACCESS_KEY      # AWS secret key for infrastructure deployment  
TF_STATE_BUCKET           # S3 bucket name for Terraform state storage
USERNAME                  # Windows server username (used by Terraform and Ansible)
PASSWORD                  # Windows server password (used by Terraform and Ansible)
WINDOWS_PASSWORD          # Windows administrator password for Ansible
```

## How to Deploy

### 🚀 Automatic Deployment
The pipeline triggers automatically on:
- Push to `main` branch
- Pull requests to `main` branch

### 🎯 Manual Deployment
You can also trigger deployments manually:

1. Go to **Actions** → **Deploy Combined Infrastructure Pipeline**
2. Click **Run workflow**
3. Select:
   - **Environment**: `staging` or `production`
   - **Skip validation**: `false` (recommended to keep validation)

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Combined Deployment Pipeline                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Stage 1: Networking           Stage 2: Network Services        │
│  ┌─────────────────┐          ┌──────────────────────┐          │
│  │ • VPC           │          │ • Elastic IP         │          │
│  │ • Subnets       │ ───────→ │ • Load Balancers     │          │
│  │ • Internet GW   │          │ • DNS Records        │          │
│  │ • Route Tables  │          └──────────────────────┘          │
│  └─────────────────┘                      │                    │
│           │                               │                    │
│           ▼                               ▼                    │
│  Stage 3: Security             Stage 4: Compute               │
│  ┌─────────────────┐          ┌──────────────────────┐          │
│  │ • Security      │          │ • EC2 Instances      │          │
│  │   Groups        │ ───────→ │ • Key Pairs          │          │
│  │ • Firewall      │          │ • User Data Scripts  │          │
│  │   Rules         │          │ • EIP Association    │          │
│  └─────────────────┘          └──────────────────────┘          │
│                                         │                      │
├─────────────────────────────────────────┼─────────────────────┤
│                                         ▼                      │
│                    Configuration & Deployment                   │
│                                                                 │
│  Ansible Configuration         .NET Application                 │
│  ┌─────────────────┐          ┌──────────────────────┐          │
│  │ • IIS Setup     │          │ • Build Application  │          │
│  │ • Server Config │ ───────→ │ • Deploy to IIS      │          │
│  │ • Prerequisites │          │ • Health Checks      │          │
│  │ • WinRM Setup   │          └──────────────────────┘          │
│  └─────────────────┘                                            │
│                                         │                      │
│                                         ▼                      │
│                      Final Validation                          │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ • Infrastructure Tests  • Application Tests              │ │
│  │ • Connectivity Tests    • Performance Tests              │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## State Management

Each Terraform stage maintains separate state files in the same S3 bucket:

```
s3://your-tfstate-bucket/
├── stage1-networking/terraform.tfstate
├── stage2-networking-services/terraform.tfstate  
├── stage3-security/terraform.tfstate
└── stage4-compute/terraform.tfstate
```

This approach provides:
- ✅ **Isolated failures**: Issues in one stage don't affect others
- ✅ **Parallel deployment**: Independent stages can run simultaneously  
- ✅ **Selective updates**: Deploy only changed components
- ✅ **Better rollbacks**: Rollback individual stages without affecting others

## Inter-Stage Communication

Stages communicate using AWS Systems Manager (SSM) parameters:

### Stage 1 → Other Stages
```
/terraform/stage1/vpc_id
/terraform/stage1/public_subnet_id  
/terraform/stage1/internet_gateway_id
```

### Stage 2 → Stage 4
```
/terraform/stage2/eip_allocation_id
/terraform/stage2/eip_public_ip
```

### Stage 3 → Stage 4
```
/terraform/stage3/security_group_id
```

### Stage 4 → Ansible & App Deployment
```
/terraform/stage4/windows_instance_id
/terraform/stage4/windows_public_ip
/terraform/stage4/windows_private_ip
```

## Reusable Workflow Templates

The pipeline uses three reusable workflow templates:

### 🏗️ `template-terraform.yml`
- Handles all Terraform stages
- Supports different backend configurations
- Includes USERNAME/PASSWORD variables
- Provides stage-specific outputs

### 🔧 `template-ansible.yml`  
- Configures Windows servers
- Installs IIS and prerequisites
- Sets up WinRM for remote management
- Supports selective playbook execution

### 📱 `template-dotnet-app.yml`
- Builds .NET applications
- Deploys to IIS
- Performs health checks
- Returns application URLs

## Validation & Monitoring

### Infrastructure Validation
The `validate-deployment.sh` script checks:
- ✅ VPC and networking components
- ✅ Security groups and rules
- ✅ EC2 instances and health
- ✅ Elastic IP associations
- ✅ Application accessibility

### Application Health Checks
- HTTP endpoint testing
- IIS service validation  
- WinRM connectivity
- Application performance

## Deployment Output

After successful deployment, you'll receive:

```
🎉 Deployment completed successfully!
🌐 Application URL: http://YOUR_EIP_ADDRESS
🖥️  RDP Access: YOUR_EIP_ADDRESS:3389
```

## Troubleshooting

### Common Issues

1. **State Bucket Access**
   ```
   Error: Access denied to S3 bucket
   Solution: Verify AWS credentials and bucket permissions
   ```

2. **SSM Parameter Not Found**
   ```
   Error: Parameter /terraform/stage1/vpc_id not found
   Solution: Ensure previous stage completed successfully
   ```

3. **Instance Not Ready**
   ```
   Error: WinRM connection failed
   Solution: Wait for instance to complete boot process (5-10 minutes)
   ```

### Debug Mode

Enable debug output in workflows:
```yaml
- name: Debug Terraform
  run: terraform plan -var="username=${{ secrets.USERNAME }}" -var="password=${{ secrets.PASSWORD }}"
  env:
    TF_LOG: DEBUG
```

## Security Considerations

- 🔒 All sensitive data uses GitHub secrets
- 🔒 Username/password are marked as sensitive in Terraform
- 🔒 WinRM uses authentication and encryption
- 🔒 Security groups restrict access to necessary ports only
- 🔒 S3 state bucket has encryption and versioning enabled

## Customization

### Adding New Stages
1. Create new stage directory: `terraform/stage5-monitoring/`
2. Add stage to `deploy-combined-pipeline.yml`
3. Update dependencies as needed

### Custom Applications
1. Modify `template-dotnet-app.yml` for your application type
2. Update deployment paths and configurations
3. Add application-specific health checks

### Different Environments
Use different variable files or override variables:
```yaml
- name: Terraform Plan
  run: terraform plan -var-file="environments/${{ inputs.environment }}.tfvars"
```

## Performance Tips

- Stages 2 and 3 can run in parallel after Stage 1 completes
- Use selective deployment for faster updates
- Consider using Terraform workspaces for multiple environments
- Cache Terraform providers and modules where possible

## Next Steps

1. **Monitor**: Set up CloudWatch monitoring for your infrastructure
2. **Scale**: Add auto-scaling groups and load balancers  
3. **Secure**: Implement WAF and additional security layers
4. **Optimize**: Use reserved instances and cost optimization
5. **Backup**: Set up automated backups for your application and data