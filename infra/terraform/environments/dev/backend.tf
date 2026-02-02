terraform {
  backend "s3" {
    bucket         = "ecr-platform-tfstate-account2-us-east-1"
    key            = "ecr-platform/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ecr-platform-tflock-account2-us-east-1"
    encrypt        = true
  }
}
