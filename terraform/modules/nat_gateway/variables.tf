variable "name" {
  description = "Name of the NAT Gateway"
  type        = string
}

variable "allocation_id" {
  description = "Allocation ID of the Elastic IP"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet"
  type        = string
}

variable "tags" {
  description = "Tags to assign to the NAT Gateway"
  type        = map(string)
  default     = {}
}
