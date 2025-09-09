variable "name" {
  description = "Name of the route table"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "routes" {
  description = "List of routes"
  type = list(object({
    cidr_block  = string
    gateway_id  = string
    gateway_key = optional(string)
  }))
  default = []
}

variable "tags" {
  description = "Tags to assign to the route table"
  type        = map(string)
  default     = {}
}
