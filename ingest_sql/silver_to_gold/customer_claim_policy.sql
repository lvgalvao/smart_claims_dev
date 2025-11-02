-- Gold - Join de claims com policies e customers
-- Cria uma visão unificada de sinistros com informações de apólices e clientes
-- Tabela streaming - processa novos dados incrementalmente

CREATE OR REFRESH STREAMING TABLE smart_claims_dev.03_gold.customer_claim_policy
COMMENT "Sinistros (claims) unidos com apólices (policies) e clientes (customers)"
TBLPROPERTIES ("quality" = "gold")
AS
SELECT
  -- Colunas do Claim
  c.claim_no,
  c.policy_no,
  c.claim_date,
  c.incident_date,
  c.incident_hour,
  c.incident_type,
  c.severity,
  c.total AS claim_total,
  c.injury,
  c.property,
  c.vehicle,
  c.collision_type,
  c.number_of_vehicles_involved,
  c.age,
  c.insured_relationship,
  c.months_as_customer,
  c.number_of_witnesses,
  c.suspicious_activity,
  
  -- Colunas do Policy
  p.cust_id,
  p.policytype,
  p.pol_issue_date,
  p.pol_eff_date,
  p.pol_expiry_date,
  p.make,
  p.model,
  p.model_year,
  p.chassis_no,
  p.use_of_vehicle,
  p.product,
  p.sum_insured,
  p.premium,
  p.deductible,
  
  -- Colunas do Customer
  cust.customer_id,
  cust.name AS customer_name,
  cust.date_of_birth AS customer_date_of_birth,
  cust.borough,
  cust.neighborhood,
  cust.zip_code,
  
  -- Construir endereço para possível geocoding posterior
  CONCAT(
    COALESCE(cust.neighborhood, ''), 
    ', ', 
    COALESCE(cust.borough, ''), 
    ', NY ', 
    COALESCE(cust.zip_code, '')
  ) AS address,
  
  -- Metadados
  c.input_file AS claim_input_file,
  c.ingested_at AS claim_ingested_at,
  current_timestamp() AS joined_at
FROM STREAM(smart_claims_dev.02_silver.claim) c
INNER JOIN STREAM(smart_claims_dev.02_silver.policy) p
  ON c.policy_no = p.policy_no
INNER JOIN STREAM(smart_claims_dev.02_silver.customer) cust
  ON p.cust_id = cust.customer_id;

