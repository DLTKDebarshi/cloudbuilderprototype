#!/bin/bash

# Web Application Test Script
# Tests the deployed .NET application accessibility

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
AWS_REGION="${AWS_REGION:-us-east-1}"

# Function to get SSM parameter value
get_ssm_parameter() {
    local param_name=$1
    aws ssm get-parameter --name "$param_name" --region "$AWS_REGION" --query 'Parameter.Value' --output text 2>/dev/null || echo ""
}

# Function to test web application
test_web_application() {
    echo -e "${BLUE}🌐 Testing Web Application${NC}"
    
    local public_ip=$(get_ssm_parameter "/terraform/stage4/instance/web_server/public_ip")
    
    if [ -z "$public_ip" ]; then
        echo -e "${RED}❌ Could not retrieve web server public IP from SSM${NC}"
        return 1
    fi
    
    echo "Testing web application at: http://$public_ip"
    
    # Test with timeout and retries
    local max_retries=10
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        echo -e "${YELLOW}⏳ Testing attempt $((retry_count + 1))/$max_retries...${NC}"
        
        if curl -s --max-time 10 "http://$public_ip" > /dev/null; then
            echo -e "${GREEN}✅ Web application is accessible at http://$public_ip${NC}"
            echo "🎉 Application URL: http://$public_ip"
            return 0
        else
            ((retry_count++))
            if [ $retry_count -lt $max_retries ]; then
                echo -e "${YELLOW}⏳ Attempt failed, retrying in 30 seconds...${NC}"
                sleep 30
            fi
        fi
    done
    
    echo -e "${RED}❌ Web application is not accessible after $max_retries attempts${NC}"
    echo "🔍 Troubleshooting tips:"
    echo "  - Ensure IIS is installed and running"
    echo "  - Check if .NET application is deployed"
    echo "  - Verify security group allows HTTP (port 80)"
    echo "  - Check Windows Firewall settings"
    return 1
}

# Main execution
echo "🚀 Starting Web Application Test"
test_web_application
exit_code=$?

if [ $exit_code -eq 0 ]; then
    echo -e "${GREEN}🎉 Web application test completed successfully!${NC}"
else
    echo -e "${RED}❌ Web application test failed!${NC}"
fi

exit $exit_code
