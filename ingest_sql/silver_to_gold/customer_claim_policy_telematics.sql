-- Gold - Join final de customer_claim_policy com telemetria agregada
-- Adiciona dados de telemetria agregados aos sinistros
-- Nota: Geocoding de endereços pode ser feito posteriormente via Python/Spark se necessário
-- Tabela streaming - processa novos dados incrementalmente

CREATE OR REFRESH STREAMING TABLE smart_claims_dev.03_gold.customer_claim_policy_telematics (
  CONSTRAINT valid_borough EXPECT (borough IS NOT NULL)
)
COMMENT "Sinistros completos com apólices, clientes e telemetria agregada"
TBLPROPERTIES ("quality" = "gold")
AS
SELECT
  -- Todas as colunas de customer_claim_policy
  ccp.claim_no,
  ccp.policy_no,
  ccp.claim_date,
  ccp.incident_date,
  ccp.incident_hour,
  ccp.incident_type,
  ccp.severity,
  ccp.claim_total,
  ccp.injury,
  ccp.property,
  ccp.vehicle,
  ccp.collision_type,
  ccp.number_of_vehicles_involved,
  ccp.age,
  ccp.insured_relationship,
  ccp.months_as_customer,
  ccp.number_of_witnesses,
  ccp.suspicious_activity,
  ccp.cust_id,
  ccp.policytype,
  ccp.pol_issue_date,
  ccp.pol_eff_date,
  ccp.pol_expiry_date,
  ccp.make,
  ccp.model,
  ccp.model_year,
  ccp.chassis_no,
  ccp.use_of_vehicle,
  ccp.product,
  ccp.sum_insured,
  ccp.premium,
  ccp.deductible,
  ccp.customer_id,
  ccp.customer_name,
  ccp.customer_date_of_birth,
  ccp.borough,
  ccp.neighborhood,
  ccp.zip_code,
  ccp.address,
  
  -- Colunas de telemetria agregada
  t.telematics_speed,
  t.telematics_latitude,
  t.telematics_longitude,
  t.telematics_event_count,
  t.first_event_timestamp,
  t.last_event_timestamp,
  
  -- Campos para geocoding (podem ser populados posteriormente)
  -- Por enquanto NULL, podem ser preenchidos via processo separado de geocoding
  CAST(NULL AS DOUBLE) AS geocoded_latitude,
  CAST(NULL AS DOUBLE) AS geocoded_longitude,
  
  -- Metadados
  ccp.claim_input_file,
  ccp.claim_ingested_at,
  ccp.joined_at,
  t.aggregated_at AS telematics_aggregated_at,
  current_timestamp() AS final_joined_at
FROM STREAM(smart_claims_dev.03_gold.customer_claim_policy) ccp
LEFT JOIN smart_claims_dev.03_gold.aggregated_telematics t
  ON ccp.chassis_no = t.chassis_no
WHERE ccp.borough IS NOT NULL;

