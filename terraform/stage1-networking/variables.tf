# Stage 1 Networking Variables - Following your GitHub repository style

# Simple variables with default = {} pattern
variable "vpcs" {
  description = "Map of VPC configurations"
  type = map(object({
    cidr_block           = string
    enable_dns_hostnames = optional(bool, true)
    enable_dns_support   = optional(bool, true)
    tags                 = optional(map(string), {})
  }))
  default = {}
}

variable "internet_gateways" {
  description = "Map of Internet Gateway configurations"
  type = map(object({
    vpc_key = string
    tags    = optional(map(string), {})
  }))
  default = {}
}

variable "route_tables" {
  description = "Map of Route Table configurations"
  type = map(object({
    vpc_key = string
    routes = optional(list(object({
      cidr_block  = string
      gateway_id  = string
      gateway_key = optional(string)
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "subnets" {
  description = "Map of Subnet configurations"
  type = map(object({
    vpc_key                 = string
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = optional(bool, false)
    tags                    = optional(map(string), {})
  }))
  default = {}
}