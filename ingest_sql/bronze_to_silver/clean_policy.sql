CREATE OR REFRESH STREAMING TABLE 02_silver.policy (
  CONSTRAINT valid_policy_no EXPECT (policy_no IS NOT NULL)
) AS
SELECT
  policy_no,
  ABS(CAST(premium AS DOUBLE)) AS premium,
  *
EXCEPT (premium)
FROM STREAM(01_bronze.policy);
