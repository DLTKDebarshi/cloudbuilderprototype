variable "name" {
  description = "Name of the instance"
  type        = string
}

variable "instance_type" {
  description = "Type of instance to launch"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet to launch the instance in"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to assign to the instance"
  type        = list(string)
}

variable "user_data" {
  description = "User data to provide when launching the instance"
  type        = string
  default     = null
}

variable "key_name" {
  description = "Key name for EC2 instance access"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to assign to the instance"
  type        = map(string)
  default     = {}
}
