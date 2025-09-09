variable "name" {
  description = "Name of the Elastic IP"
  type        = string
}

variable "tags" {
  description = "Tags to assign to the Elastic IP"
  type        = map(string)
  default     = {}
}
