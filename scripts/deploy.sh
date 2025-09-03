#!/bin/bash
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
ansible-playbook $PLAYBOOKS_DIR/windows/iis_configuration/setup_iis.yml \
    -e windows_password="$WINDOWS_PASSWORD" \
    -e ansible_host="$WINDOWS_PUBLIC_IP"

echo "✅ Deployment completed successfully!"
echo "🌐 Access your Windows server at: $WINDOWS_PUBLIC_IP"
