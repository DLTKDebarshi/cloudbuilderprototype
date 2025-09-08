variable "lb_name" {
  description = "Name of the load balancer"
  type        = string
}

variable "internal" {
  description = "If true, the LB will be internal"
  type        = bool
  default     = false
}

variable "security_groups" {
  description = "A list of security group IDs to assign to the LB"
  type        = list(string)
}

variable "subnets" {
  description = "A list of subnet IDs to attach to the LB"
  type        = list(string)
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "The identifier of the VPC"
  type        = string
}

variable "target_port" {
  description = "The port on which targets receive traffic"
  type        = number
  default     = 80
}

variable "target_protocol" {
  description = "The protocol to use for routing traffic to the targets"
  type        = string
  default     = "HTTP"
}

variable "health_check_path" {
  description = "The destination for the health check request"
  type        = string
  default     = "/"
}

variable "listener_port" {
  description = "The port on which the load balancer is listening"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "The protocol for connections from clients to the load balancer"
  type        = string
  default     = "HTTP"
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}