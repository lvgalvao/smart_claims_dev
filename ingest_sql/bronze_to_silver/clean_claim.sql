CREATE OR REFRESH STREAMING TABLE smart_claims_dev.02_silver.claim (
  CONSTRAINT valid_claim_number EXPECT (claim_no IS NOT NULL),
  CONSTRAINT valid_incident_hour EXPECT (incident_hour BETWEEN 0 AND 23)
) AS
SELECT
  claim_no,
  TO_DATE(claim_date)                            AS claim_date,
  TO_DATE(incident_date)                         AS incident_date,
  TO_DATE(license_issue_date, 'dd-MM-yyyy')      AS license_issue_date,
  incident_hour,
  *
EXCEPT (claim_date, incident_date, license_issue_date)
FROM STREAM(smart_claims_dev.01_bronze.claim);
