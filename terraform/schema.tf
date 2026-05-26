# ==========================================
# スキーマ定義（SYSADMINで実行）
# ==========================================
# スキーマの作成
resource "snowflake_schema" "training_raw" {
  database = snowflake_database.training_db.name
  name     = "RAW"
  comment  = "Raw mail data ingested from S3."
}
resource "snowflake_schema" "training_normalized" {
  database = snowflake_database.training_db.name
  name     = "NORMALIZED"
  comment  = "Processed data for Streamlit."
}

# ==========================================
# スキーマへの権限付与
# ==========================================
# RAW・NORMALIZEDスキーマ
resource "snowflake_grant_privileges_to_account_role" "training_schema_grants" {
  for_each = toset([
    "${snowflake_database.training_db.name}.${snowflake_schema.training_raw.name}",
    "${snowflake_database.training_db.name}.${snowflake_schema.training_normalized.name}"
  ])
  account_role_name = "FR_ANCHOR_DEMO_ROLE"
  privileges = [
    "USAGE",
    "MODIFY",
    "MONITOR",
    "CREATE TABLE",
    "CREATE STAGE",
    "CREATE PIPE",
    "CREATE TASK",
    "CREATE FILE FORMAT",
    "CREATE STREAM",
    "CREATE VIEW",
    "CREATE PROCEDURE",
    "CREATE STREAMLIT"
  ]
  on_schema {
    schema_name = each.value
  }
  depends_on = [
    snowflake_schema.training_raw,
    snowflake_schema.training_normalized
  ]
}
# FUTUREスキーマ
resource "snowflake_grant_privileges_to_account_role" "future_schema_training" {
  account_role_name = "FR_ANCHOR_DEMO_ROLE"
  privileges = [
    "USAGE",
    "MODIFY",
    "MONITOR",
    "CREATE TABLE",
    "CREATE STAGE",
    "CREATE PIPE",
    "CREATE TASK",
    "CREATE FILE FORMAT",
    "CREATE STREAM",
    "CREATE VIEW",
    "CREATE PROCEDURE",
    "CREATE STREAMLIT"
  ]
  on_schema {
    future_schemas_in_database = snowflake_database.training_db.name
  }
}

# ==========================================
# WAREHOUSEへの権限付与
# ==========================================
resource "snowflake_grant_privileges_to_account_role" "training_wh_usage" {
  account_role_name = "FR_ANCHOR_DEMO_ROLE"
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = "SNOWFLAKE_LEARNING_WH"
  }
}