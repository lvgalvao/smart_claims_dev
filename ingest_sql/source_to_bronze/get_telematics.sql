-- Target do pipeline: smart_claims_dev.01_bronze

CREATE OR REFRESH STREAMING LIVE TABLE smart_claims_dev.01_bronze.telematics
COMMENT "Bronze — telemetria bruta a partir de Parquet em Volumes (SELECT * + metadata)"
TBLPROPERTIES ("quality" = "bronze")
AS
SELECT
  *,
  _metadata.file_path               AS input_file,
  _metadata.file_modification_time  AS input_file_mtime,
  current_timestamp()               AS ingested_at
FROM cloud_files(
  "/Volumes/smart_claims_dev/00_landing/telematics",
  "parquet",
  map(
    -- Evolução de schema habilitada
    "cloudFiles.schemaEvolutionMode", "addNewColumns"
  )
);
