variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the subnet"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "public-subnet"
}

variable "map_public_ip_on_launch" {
  description = "Map public IP on launch"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}