# Stage 4 Compute Variables - Following your GitHub repository style

# Simple variables with default = {} pattern
variable "instances" {
  description = "Map of Instance configurations"
  type = map(object({
    instance_type      = string
    subnet_key         = string
    security_group_key = string
    associate_eip      = optional(bool, false)
    eip_key            = optional(string)
    user_data          = optional(string)
    tags               = optional(map(string), {})
  }))
  default = {}
}

variable "username" {
  description = "Username from GitHub secrets"
  type        = string
  sensitive   = true
  default     = "azureadmin"
}

variable "password" {
  description = "Password from GitHub secrets"
  type        = string
  sensitive   = true
  default     = "`5q;7eRH9&0#s$9D.£V+"
}
