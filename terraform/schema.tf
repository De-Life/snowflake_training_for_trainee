resource "snowflake_schema" "tf_test_schema" {
  database = snowflake_database.tf_test_db.name
  name     = "TF_TEST_SCHEMA"
  comment  = "Test schema created by Terraform"
}