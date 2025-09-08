variable "domain_name" {
  description = "The domain name for the hosted zone"
  type        = string
}

variable "zone_name" {
  description = "Name of the hosted zone"
  type        = string
  default     = "main-zone"
}

variable "records" {
  description = "List of DNS records to create"
  type = list(object({
    name    = string
    type    = string
    ttl     = number
    records = list(string)
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}