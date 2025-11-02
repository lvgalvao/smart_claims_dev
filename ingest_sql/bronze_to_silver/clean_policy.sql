CREATE OR REFRESH STREAMING TABLE smart_claims_dev.02_silver.policy (
  CONSTRAINT valid_policy_no EXPECT (policy_no IS NOT NULL)
) AS
SELECT
  CAST(POLICY_NO AS BIGINT) AS policy_no,
  CAST(CUST_ID AS BIGINT) AS cust_id,
  POLICYTYPE AS policytype,
  TO_DATE(POL_ISSUE_DATE) AS pol_issue_date,
  TO_DATE(POL_EFF_DATE) AS pol_eff_date,
  TO_DATE(POL_EXPIRY_DATE) AS pol_expiry_date,
  MAKE AS make,
  MODEL AS model,
  CAST(MODEL_YEAR AS INT) AS model_year,
  CHASSIS_NO AS chassis_no,
  USE_OF_VEHICLE AS use_of_vehicle,
  PRODUCT AS product,
  CAST(SUM_INSURED AS DOUBLE) AS sum_insured,
  ABS(CAST(PREMIUM AS DOUBLE)) AS premium,
  CAST(DEDUCTABLE AS INT) AS deductible,
  input_file,
  input_file_mtime,
  ingested_at
FROM STREAM(smart_claims_dev.01_bronze.policy);
