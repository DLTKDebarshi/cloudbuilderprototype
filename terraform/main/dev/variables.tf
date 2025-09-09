variable "vpcs" {
  default = {}
}

variable "internet_gateways" {
  default = {}
}

variable "nat_gateways" {
  default = {}
}

variable "route_tables" {
  default = {}
}

variable "route_associations" {
  default = {}
}

variable "security_groups" {
  default = {}
}

variable "instances" {
  default = {}
}

variable "elastic_ips" {
  default = {}
}

variable "username" {
  type      = string
  sensitive = true
}

variable "password" {
  type      = string
  sensitive = true
}
