variable "name" {
  description = "The name of the ALB"
  type        = string
}

variable "subnets" {
  description = "The subnets in which to create the ALB"
  type        = list(string)
}

variable "target_group_name" {
  description = "The name of the target group"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "security_group_name" {
  description = "The name of the ALB security group"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "The allowed CIDR blocks for incoming traffic"
  type        = list(string)
}
