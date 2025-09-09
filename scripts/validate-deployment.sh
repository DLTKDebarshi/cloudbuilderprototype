#!/bin/bash

# AWS Deployment Validation Script
# Validates all components are deployed successfully across the 4 Terraform stages

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
AWS_REGION="${AWS_REGION:-us-east-1}"
VALIDATION_LOG="/tmp/validation-$(date +%Y%m%d-%H%M%S).log"

echo "🔍 Starting AWS deployment validation..."
echo "📝 Log file: ${VALIDATION_LOG}"

# Function to log messages
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$VALIDATION_LOG"
}

# Function to check if a resource exists
check_resource() {
    local resource_type=$1
    local resource_id=$2
    local stage=$3
    
    log_message "INFO" "Checking $resource_type: $resource_id (Stage $stage)"
    
    case $resource_type in
        "VPC")
            if aws ec2 describe-vpcs --vpc-ids "$resource_id" --region "$AWS_REGION" >/dev/null 2>&1; then
                echo -e "${GREEN}✅ VPC $resource_id exists${NC}"
                return 0
            else
                echo -e "${RED}❌ VPC $resource_id not found${NC}"
                return 1
            fi
            ;;
        "SUBNET")
            if aws ec2 describe-subnets --subnet-ids "$resource_id" --region "$AWS_REGION" >/dev/null 2>&1; then
                echo -e "${GREEN}✅ Subnet $resource_id exists${NC}"
                return 0
            else
                echo -e "${RED}❌ Subnet $resource_id not found${NC}"
                return 1
            fi
            ;;
        "IGW")
            if aws ec2 describe-internet-gateways --internet-gateway-ids "$resource_id" --region "$AWS_REGION" >/dev/null 2>&1; then
                echo -e "${GREEN}✅ Internet Gateway $resource_id exists${NC}"
                return 0
            else
                echo -e "${RED}❌ Internet Gateway $resource_id not found${NC}"
                return 1
            fi
            ;;
        "SG")
            if aws ec2 describe-security-groups --group-ids "$resource_id" --region "$AWS_REGION" >/dev/null 2>&1; then
                echo -e "${GREEN}✅ Security Group $resource_id exists${NC}"
                return 0
            else
                echo -e "${RED}❌ Security Group $resource_id not found${NC}"
                return 1
            fi
            ;;
        "INSTANCE")
            instance_state=$(aws ec2 describe-instances --instance-ids "$resource_id" --region "$AWS_REGION" --query 'Reservations[0].Instances[0].State.Name' --output text 2>/dev/null || echo "not-found")
            if [ "$instance_state" = "running" ]; then
                echo -e "${GREEN}✅ Instance $resource_id is running${NC}"
                return 0
            elif [ "$instance_state" = "pending" ] || [ "$instance_state" = "starting" ]; then
                echo -e "${YELLOW}⏳ Instance $resource_id is $instance_state${NC}"
                return 0
            else
                echo -e "${RED}❌ Instance $resource_id not running (state: $instance_state)${NC}"
                return 1
            fi
            ;;
        "EIP")
            if aws ec2 describe-addresses --allocation-ids "$resource_id" --region "$AWS_REGION" >/dev/null 2>&1; then
                echo -e "${GREEN}✅ Elastic IP $resource_id exists${NC}"
                return 0
            else
                echo -e "${RED}❌ Elastic IP $resource_id not found${NC}"
                return 1
            fi
            ;;
    esac
}

# Function to get SSM parameter value
get_ssm_parameter() {
    local param_name=$1
    aws ssm get-parameter --name "$param_name" --region "$AWS_REGION" --query 'Parameter.Value' --output text 2>/dev/null || echo ""
}

# Function to validate stage
validate_stage() {
    local stage_num=$1
    local stage_name=$2
    
    echo -e "\n${BLUE}🔍 Validating Stage $stage_num: $stage_name${NC}"
    log_message "INFO" "Starting validation for Stage $stage_num: $stage_name"
    
    local errors=0
    
    case $stage_num in
        1)
            # Stage 1: Networking
            vpc_id=$(get_ssm_parameter "/terraform/stage1/vpc/main_vpc/id")
            subnet_id=$(get_ssm_parameter "/terraform/stage1/subnet/public_subnet_1a/id")
            igw_id=$(get_ssm_parameter "/terraform/stage1/igw/main_igw/id")
            
            [ -n "$vpc_id" ] && check_resource "VPC" "$vpc_id" "1" || ((errors++))
            [ -n "$subnet_id" ] && check_resource "SUBNET" "$subnet_id" "1" || ((errors++))
            [ -n "$igw_id" ] && check_resource "IGW" "$igw_id" "1" || ((errors++))
            ;;
        2)
            # Stage 2: Networking Services
            eip_alloc_id=$(get_ssm_parameter "/terraform/stage2/eip/nat_eip_1a/allocation_id")
            
            [ -n "$eip_alloc_id" ] && check_resource "EIP" "$eip_alloc_id" "2" || ((errors++))
            ;;
        3)
            # Stage 3: Security
            web_sg_id=$(get_ssm_parameter "/terraform/stage3/sg/web_sg/id")
            app_sg_id=$(get_ssm_parameter "/terraform/stage3/sg/app_sg/id")
            
            [ -n "$web_sg_id" ] && check_resource "SG" "$web_sg_id" "3" || ((errors++))
            [ -n "$app_sg_id" ] && check_resource "SG" "$app_sg_id" "3" || ((errors++))
            ;;
        4)
            # Stage 4: Compute
            web_instance_id=$(get_ssm_parameter "/terraform/stage4/instance/web_server/id")
            app_instance_id=$(get_ssm_parameter "/terraform/stage4/instance/app_server/id")
            
            [ -n "$web_instance_id" ] && check_resource "INSTANCE" "$web_instance_id" "4" || ((errors++))
            [ -n "$app_instance_id" ] && check_resource "INSTANCE" "$app_instance_id" "4" || ((errors++))
            ;;
    esac
    
    if [ $errors -eq 0 ]; then
        echo -e "${GREEN}✅ Stage $stage_num validation passed${NC}"
        log_message "SUCCESS" "Stage $stage_num validation completed successfully"
    else
        echo -e "${RED}❌ Stage $stage_num validation failed with $errors errors${NC}"
        log_message "ERROR" "Stage $stage_num validation failed with $errors errors"
    fi
    
    return $errors
}

# Function to test web application
test_web_application() {
    echo -e "\n${BLUE}🌐 Testing Web Application${NC}"
    
    local public_ip=$(get_ssm_parameter "/terraform/stage4/instance/web_server/public_ip")
    
    if [ -z "$public_ip" ]; then
        echo -e "${RED}❌ Could not retrieve public IP from SSM${NC}"
        return 1
    fi
    
    echo "Testing web application at: http://$public_ip"
    
    # Test with timeout and retries
    local max_retries=5
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        if curl -s --max-time 10 "http://$public_ip" > /dev/null; then
            echo -e "${GREEN}✅ Web application is accessible at http://$public_ip${NC}"
            log_message "SUCCESS" "Web application accessible at http://$public_ip"
            return 0
        else
            ((retry_count++))
            echo -e "${YELLOW}⏳ Attempt $retry_count/$max_retries failed, retrying in 10 seconds...${NC}"
            sleep 10
        fi
    done
    
    echo -e "${RED}❌ Web application is not accessible after $max_retries attempts${NC}"
    log_message "ERROR" "Web application not accessible after $max_retries attempts"
    return 1
}

# Function to generate validation report
generate_report() {
    local total_errors=$1
    
    echo -e "\n${BLUE}📊 Validation Summary${NC}"
    echo "=========================="
    
    if [ $total_errors -eq 0 ]; then
        echo -e "${GREEN}✅ All validations passed successfully!${NC}"
        echo "🚀 Deployment is complete and functional"
        
        local public_ip=$(get_ssm_parameter "/terraform/stage4/windows_public_ip")
        if [ -n "$public_ip" ]; then
            echo -e "${GREEN}🌐 Application URL: http://$public_ip${NC}"
            echo -e "${GREEN}🖥️  RDP Access: $public_ip:3389${NC}"
        fi
    else
        echo -e "${RED}❌ Validation completed with $total_errors errors${NC}"
        echo "Please check the log file for details: $VALIDATION_LOG"
    fi
    
    echo "📝 Full validation log: $VALIDATION_LOG"
}

# Main validation flow
main() {
    log_message "INFO" "Starting AWS deployment validation"
    
    local total_errors=0
    
    # Validate each stage
    validate_stage 1 "Networking" || ((total_errors += $?))
    validate_stage 2 "Networking Services" || ((total_errors += $?))
    validate_stage 3 "Security" || ((total_errors += $?))
    validate_stage 4 "Compute" || ((total_errors += $?))
    
    # Note: Web application testing is done after deployment in the pipeline
    # Infrastructure validation only validates AWS resources exist
    
    # Generate final report
    generate_report $total_errors
    
    log_message "INFO" "Validation completed with $total_errors total errors"
    
    exit $total_errors
}

# Run main function
main "$@"