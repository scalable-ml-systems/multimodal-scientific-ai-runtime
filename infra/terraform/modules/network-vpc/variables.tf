variable "name" { type = string }
variable "cidr" { type = string }

variable "az_count" {
  type    = number
  default = 2
}

variable "one_nat_gateway" {
  type    = bool
  default = true
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Whether to create NAT gateway(s). If false, private subnets have no internet egress."
  default     = true
}
