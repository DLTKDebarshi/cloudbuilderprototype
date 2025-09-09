# Stage 4 Compute Variables

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

variable "username" {
  description = "Username from GitHub secrets"
  type        = string
  sensitive   = true
}

variable "password" {
  description = "Password from GitHub secrets"
  type        = string
  sensitive   = true
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "CloudBuilder"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Stage       = "compute"
  }
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
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7... # Add your default public key or leave empty"
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