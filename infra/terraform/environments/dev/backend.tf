terraform {
  backend "s3" {
    bucket         = "multimodal-scientific-tfstate-account2-us-east-1"
    key            = "multimodal-scientific/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "multimodal-scientific-tfstate-account2-us-east-1-tf-lock"
    encrypt        = true
  }
}
