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
