CREATE OR REFRESH STREAMING TABLE smart_claims_dev.02_silver.claim (
  CONSTRAINT valid_claim_number EXPECT (claim_no IS NOT NULL),
  CONSTRAINT valid_incident_hour EXPECT (incident_hour BETWEEN 0 AND 23)
) AS
SELECT
  claim_no,
  CAST(policy_no AS BIGINT) AS policy_no,
  TO_DATE(claim_date) AS claim_date,
  CAST(months_as_customer AS INT) AS months_as_customer,
  CAST(injury AS DOUBLE) AS injury,
  CAST(property AS DOUBLE) AS property,
  CAST(vehicle AS DOUBLE) AS vehicle,
  CAST(total AS DOUBLE) AS total,
  collision_type AS collision_type,
  CAST(number_of_vehicles_involved AS INT) AS number_of_vehicles_involved,
  CAST(age AS DOUBLE) AS age,
  insured_relationship AS insured_relationship,
  TO_DATE(license_issue_date, 'dd-MM-yyyy') AS license_issue_date,
  TO_DATE(date) AS incident_date,
  CAST(hour AS INT) AS incident_hour,
  type AS incident_type,
  severity AS severity,
  CAST(number_of_witnesses AS INT) AS number_of_witnesses,
  CAST(suspicious_activity AS BOOLEAN) AS suspicious_activity,
  input_file,
  input_file_mtime,
  ingested_at
FROM STREAM(smart_claims_dev.01_bronze.claim);
