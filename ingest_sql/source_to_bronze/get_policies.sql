CREATE OR REFRESH STREAMING LIVE TABLE smart_claims_dev.01_bronze.policy
COMMENT "Bronze — apólices (policies) a partir de 00_landing/sql_server/policies.csv"
TBLPROPERTIES ("quality" = "bronze")
AS
SELECT
  *,
  _metadata.file_path               AS input_file,
  _metadata.file_modification_time  AS input_file_mtime,
  current_timestamp()               AS ingested_at
FROM cloud_files(
  "/Volumes/smart_claims_dev/00_landing/sql_server",
  "csv",
  map(
    "header", "true",
    "cloudFiles.inferColumnTypes", "true",
    "cloudFiles.schemaEvolutionMode", "addNewColumns",
    "pathGlobFilter", "policies.csv"
  )
);