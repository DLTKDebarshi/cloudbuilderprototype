variable "instance_id" {
  description = "The instance ID to associate with the Elastic IP"
  type        = string
  default     = null
}

variable "eip_name" {
  description = "Name of the Elastic IP"
  type        = string
  default     = "main-eip"
}

variable "internet_gateway_id" {
  description = "The Internet Gateway ID for dependency"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}