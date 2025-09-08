variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "igw_name" {
  description = "Name of the Internet Gateway"
  type        = string
  default     = "main-igw"
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}