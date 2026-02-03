module "tf_lock" {
  source     = "../../modules/tf_lock_dynamodb"
  table_name = "${var.project}-${var.env}-tf-lock"
  tags       = local.tags
}
