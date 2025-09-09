variable "name" {
  description = "Name of the Internet Gateway"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to attach the Internet Gateway to"
  type        = string
}

variable "tags" {
  description = "Tags to assign to the Internet Gateway"
  type        = map(string)
  default     = {}
}
