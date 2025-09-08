variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "internet_gateway_id" {
  description = "The Internet Gateway ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to associate with the route table"
  type        = list(string)
  default     = []
}

variable "route_table_name" {
  description = "Name of the route table"
  type        = string
  default     = "public-route-table"
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}