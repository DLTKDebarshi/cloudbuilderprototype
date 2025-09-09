variable "name" {
  description = "Name of the route table"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

# Routes will be managed separately to keep module simple

variable "tags" {
  description = "Tags to assign to the route table"
  type        = map(string)
  default     = {}
}
