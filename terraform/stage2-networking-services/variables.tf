# Stage 2 Networking Services Variables - Following your GitHub repository style

# Simple variables with default = {} pattern
variable "nat_gateways" {
  default = {}
}

variable "elastic_ips" {
  default = {}
}

variable "route_table_associations" {
  default = {}
}
  sensitive   = true
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "CloudBuilder"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Stage       = "networking-services"
  }
}

# Elastic IP Variables
variable "eip_name" {
  description = "Name of the Elastic IP"
  type        = string
  default     = "windows-eip"
}