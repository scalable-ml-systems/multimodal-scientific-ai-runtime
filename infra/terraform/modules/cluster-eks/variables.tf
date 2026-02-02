variable "name" { type = string }
variable "kubernetes_version" { type = string }

variable "vpc_id" { type = string }
variable "private_subnets" { type = list(string) }

variable "system_instance_type" { type = string }
variable "system_min" { type = number }
variable "system_max" { type = number }
variable "system_desired" { type = number }

variable "gpu_instance_type" { type = string }
variable "gpu_min" { type = number }
variable "gpu_max" { type = number }
variable "gpu_desired" { type = number }

variable "enable_gpu_nodegroup" {
  type        = bool
  description = "Whether to create the GPU managed node group"
  default     = false
}
