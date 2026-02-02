variable "region" {
  type    = string
  default = "us-east-1"
}

variable "state_bucket_name" {
  type        = string
  description = "S3 bucket name for Terraform remote state."
}

variable "lock_table_name" {
  type        = string
  description = "DynamoDB table name for Terraform state locking."
}
