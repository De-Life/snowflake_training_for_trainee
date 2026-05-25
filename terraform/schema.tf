# スキーマの作成
resource "snowflake_schema" "tf_test_schema" {
  database = snowflake_database.tf_test_db.name
  name     = "TF_TEST_SCHEMA"
  comment  = "Test schema created by Terraform"
}

# スキーマへのUSAGE権限
resource "snowflake_grant_privileges_to_account_role" "schema_usage" {
  account_role_name = "FR_ANCHOR_DEMO_ROLE"
  privileges        = ["USAGE", "CREATE TABLE", "CREATE VIEW"]
  on_schema {
    schema_name = "${snowflake_database.tf_test_db.name}.${snowflake_schema.tf_test_schema.name}"
  }
  depends_on = [snowflake_schema.tf_test_schema]
}

# 将来作成されるスキーマへの権限付与
resource "snowflake_grant_privileges_to_account_role" "future_schema_usage" {
  account_role_name = "FR_ANCHOR_DEMO_ROLE"
  privileges        = ["USAGE", "CREATE TABLE", "CREATE VIEW"]
  on_schema {
    future_schemas_in_database = snowflake_database.tf_test_db.name
  }
}