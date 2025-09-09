# Stage 3 Security Variables - Following your GitHub repository style

# Simple variables with default = {} pattern
variable "security_groups" {
  description = "Map of Security Group configurations"
  type = map(object({
    vpc_key     = string
    description = string
    ingress_rules = optional(list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = optional(list(string))
      description = optional(string)
    })), [])
    egress_rules = optional(list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = optional(list(string))
      description = optional(string)
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}
