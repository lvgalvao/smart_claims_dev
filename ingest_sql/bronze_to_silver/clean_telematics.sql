CREATE OR REFRESH STREAMING TABLE smart_claims_dev.02_silver.telematics (
  CONSTRAINT valid_coordinates EXPECT (latitude BETWEEN -90 AND 90 AND longitude BETWEEN -180 AND 180)
) AS
SELECT
  CAST(chassis_no AS STRING)           AS chassis_no,
  CAST(latitude AS DOUBLE)             AS latitude,
  CAST(longitude AS DOUBLE)            AS longitude,
  CAST(event_timestamp AS TIMESTAMP)   AS event_timestamp,
  CAST(speed AS DOUBLE)                AS speed,
  input_file,
  input_file_mtime,
  ingested_at
FROM STREAM(smart_claims_dev.01_bronze.telematics);
