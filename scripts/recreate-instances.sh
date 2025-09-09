#!/bin/bash

# Script to force recreation of EC2 instances for new user data
# This is useful when you've updated the user_data.ps1 script

set -e

echo "🔄 Forcing EC2 instance recreation to apply new user data..."

cd terraform/stage4-compute

echo "📝 Initializing Terraform..."
terraform init

echo "🎯 Tainting instances to force recreation..."
terraform taint 'module.instance["web_server"].aws_instance.this' || echo "Instance not found or already tainted"
terraform taint 'module.instance["app_server"].aws_instance.this' || echo "Instance not found or already tainted"

echo "🚀 Applying changes (this will recreate instances with new user data)..."
terraform apply -auto-approve

echo "✅ Instances recreated with updated user data script!"
echo "📋 New instances will have the latest WinRM/RDP configuration."
