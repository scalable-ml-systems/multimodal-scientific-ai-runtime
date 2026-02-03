variable "table_name" {
  type        = string
  description = "DynamoDB table for Terraform state locking"
}

variable "tags" {
  type        = map(string)
  description = "Standard tags"
  default     = {}
}
