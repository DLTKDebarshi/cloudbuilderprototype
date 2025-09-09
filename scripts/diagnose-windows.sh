#!/bin/bash

# Script to diagnose Windows EC2 instance configuration issues
# This script checks connectivity and helps troubleshoot RDP/WinRM issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔍 Windows EC2 Instance Diagnostic Tool${NC}"
echo "=================================================="

# Get instance information from SSM parameters
echo -e "\n${YELLOW}📋 Getting instance information...${NC}"

WEB_SERVER_IP=$(aws ssm get-parameter --name "/terraform/stage4/instance/web_server/public_ip" --region us-east-1 --query 'Parameter.Value' --output text 2>/dev/null || echo "NOT_FOUND")
APP_SERVER_IP=$(aws ssm get-parameter --name "/terraform/stage4/instance/app_server/public_ip" --region us-east-1 --query 'Parameter.Value' --output text 2>/dev/null || echo "NOT_FOUND")

WEB_SERVER_ID=$(aws ssm get-parameter --name "/terraform/stage4/instance/web_server/id" --region us-east-1 --query 'Parameter.Value' --output text 2>/dev/null || echo "NOT_FOUND")
APP_SERVER_ID=$(aws ssm get-parameter --name "/terraform/stage4/instance/app_server/id" --region us-east-1 --query 'Parameter.Value' --output text 2>/dev/null || echo "NOT_FOUND")

echo "Web Server: $WEB_SERVER_ID ($WEB_SERVER_IP)"
echo "App Server: $APP_SERVER_ID ($APP_SERVER_IP)"

# Function to test connectivity
test_connectivity() {
    local ip=$1
    local port=$2
    local service=$3
    
    echo -n "Testing $service ($ip:$port)... "
    
    if timeout 5 bash -c "</dev/tcp/$ip/$port" 2>/dev/null; then
        echo -e "${GREEN}✅ ACCESSIBLE${NC}"
        return 0
    else
        echo -e "${RED}❌ NOT ACCESSIBLE${NC}"
        return 1
    fi
}

# Test connectivity for each server
for server in "web_server" "app_server"; do
    if [ "$server" == "web_server" ]; then
        IP=$WEB_SERVER_IP
        ID=$WEB_SERVER_ID
    else
        IP=$APP_SERVER_IP
        ID=$APP_SERVER_ID
    fi
    
    if [ "$IP" != "NOT_FOUND" ] && [ "$IP" != "" ]; then
        echo -e "\n${YELLOW}🔗 Testing connectivity to $server ($IP)...${NC}"
        
        test_connectivity $IP 3389 "RDP"
        test_connectivity $IP 5985 "WinRM HTTP"
        test_connectivity $IP 5986 "WinRM HTTPS" 
        test_connectivity $IP 80 "HTTP"
        test_connectivity $IP 443 "HTTPS"
        
        # Get instance status
        echo -e "\n${YELLOW}📊 Instance Status:${NC}"
        aws ec2 describe-instance-status --instance-ids $ID --region us-east-1 --query 'InstanceStatuses[0].{Instance:InstanceStatus.Status,System:SystemStatus.Status}' --output table 2>/dev/null || echo "Could not get status"
        
        # Get console output (last few lines)
        echo -e "\n${YELLOW}📜 Console Output (last 20 lines):${NC}"
        aws ec2 get-console-output --instance-id $ID --region us-east-1 --query 'Output' --output text 2>/dev/null | tail -20 || echo "Could not get console output"
        
    else
        echo -e "\n${RED}❌ $server IP not found${NC}"
    fi
done

echo -e "\n${YELLOW}🔧 Troubleshooting Suggestions:${NC}"
echo "================================"
echo "1. If RDP is not accessible:"
echo "   - Check if Windows is still booting (wait 5-10 minutes)"
echo "   - Verify user data script completed successfully"
echo "   - Check Windows Firewall is disabled"
echo ""
echo "2. To get Windows password:"
echo "   aws ec2 get-password-data --instance-id <INSTANCE-ID> --region us-east-1"
echo ""
echo "3. To force instance recreation:"
echo "   cd terraform/stage4-compute"
echo "   terraform taint 'module.instance[\"web_server\"].aws_instance.this'"
echo "   terraform apply"
echo ""
echo "4. Check user data logs on the instance at:"
echo "   C:\\Windows\\Temp\\user_data_log.txt"
