variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "The key name to use for the instance"
  type        = string
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate with"
  type        = list(string)
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in"
  type        = string
}

variable "instance_name" {
  description = "Name of the Windows instance"
  type        = string
  default     = "windows-server"
}

variable "user_data" {
  description = "The user data to provide when launching the instance"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}