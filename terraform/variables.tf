# Variables for Terraform configuration

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
