# Stage 4 Compute Variables - Following your GitHub repository style

# Simple variables with default = {} pattern
variable "instances" {
  default = {}
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

# Compute Instances Configuration
variable "instances" {
  description = "Configuration for compute instances"
  type = map(object({
    instance_type = string
    instance_name = string
    os_type       = string
    ami_id        = optional(string)
    user_data     = optional(string)
    tags          = optional(map(string), {})
  }))
  default = {}
}