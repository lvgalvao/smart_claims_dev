CREATE OR REFRESH STREAMING TABLE smart_claims_dev.02_silver.customer (
  CONSTRAINT valid_customer_id EXPECT (customer_id IS NOT NULL),
  CONSTRAINT valid_zip_code EXPECT (zip_code IS NOT NULL AND LENGTH(zip_code) >= 5)
) AS
SELECT
  CAST(customer_id AS BIGINT)           AS customer_id,
  TO_DATE(date_of_birth, 'dd-MM-yyyy') AS date_of_birth,
  UPPER(TRIM(borough))                  AS borough,
  TRIM(neighborhood)                    AS neighborhood,
  CAST(zip_code AS STRING)              AS zip_code,
  TRIM(name)                            AS name,
  input_file,
  input_file_mtime,
  ingested_at
FROM STREAM(smart_claims_dev.01_bronze.customer);

