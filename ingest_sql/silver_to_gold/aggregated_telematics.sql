-- Gold - Agregação de dados de telemetria por chassis_no
-- Calcula médias de velocidade, latitude e longitude por veículo
-- Tabela não-streaming (batch) - agrega todos os dados disponíveis

CREATE OR REFRESH TABLE smart_claims_dev.03_gold.aggregated_telematics
COMMENT "Agregação de telemetria - médias de speed, latitude e longitude por chassis_no"
TBLPROPERTIES ("quality" = "gold")
AS
SELECT
  chassis_no,
  AVG(speed) AS telematics_speed,
  AVG(latitude) AS telematics_latitude,
  AVG(longitude) AS telematics_longitude,
  COUNT(*) AS telematics_event_count,
  MIN(event_timestamp) AS first_event_timestamp,
  MAX(event_timestamp) AS last_event_timestamp,
  current_timestamp() AS aggregated_at
FROM smart_claims_dev.02_silver.telematics
GROUP BY chassis_no;

