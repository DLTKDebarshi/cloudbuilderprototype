# Stage 2 Networking Services Variables - Following your GitHub repository style

# Simple variables with default = {} pattern
variable "elastic_ips" {
  description = "Map of Elastic IP configurations"
  type = map(object({
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "nat_gateways" {
  description = "Map of NAT Gateway configurations"
  type = map(object({
    subnet_key = string
    eip_key    = string
    tags       = optional(map(string), {})
  }))
  default = {}
}

variable "route_table_associations" {
  description = "Map of Route Table Association configurations"
  type = map(object({
    subnet_key      = string
    route_table_key = string
  }))
  default = {}
}