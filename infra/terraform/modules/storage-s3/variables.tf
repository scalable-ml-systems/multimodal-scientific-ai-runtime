variable "name" { type = string }

variable "buckets" {
  type = map(object({
    versioning     = bool
    lifecycle_days = number
  }))
}
