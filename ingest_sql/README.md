# Pipeline de Ingestão SQL - Smart Claims

Este diretório contém todos os scripts SQL para os pipelines **Delta Live Tables (DLT)** do projeto Smart Claims. Os pipelines seguem a arquitetura Medallion, processando dados desde a ingestão bruta até agregações finais prontas para consumo.

## 📊 Visão Geral do Pipeline

```mermaid
graph TB
    subgraph "00_landing - Volumes"
        V1[claims<br/>Volume]
        V2[sql_server<br/>Volume<br/>claims.csv<br/>customers.csv<br/>policies.csv]
        V3[telematics<br/>Volume<br/>*.parquet]
    end
    
    subgraph "source_to_bronze/"
        B1[get_claim.sql]
        B2[get_customers.sql]
        B3[get_policies.sql]
        B4[get_telematics.sql]
    end
    
    subgraph "01_bronze - Raw Tables"
        T1[claim<br/>TABLE]
        T2[customer<br/>TABLE]
        T3[policy<br/>TABLE]
        T4[telematics<br/>TABLE]
    end
    
    subgraph "bronze_to_silver/"
        S1[clean_claim.sql]
        S2[clean_customer.sql]
        S3[clean_policy.sql]
        S4[clean_telematics.sql]
    end
    
    subgraph "02_silver - Clean Tables"
        TS1[claim<br/>TABLE]
        TS2[customer<br/>TABLE]
        TS3[policy<br/>TABLE]
        TS4[telematics<br/>TABLE]
    end
    
    subgraph "silver_to_gold/"
        G1[aggregated_telematics.sql]
        G2[customer_claim_policy.sql]
        G3[customer_claim_policy_telematics.sql]
    end
    
    subgraph "03_gold - Aggregated Tables"
        TG1[aggregated_telematics<br/>TABLE]
        TG2[customer_claim_policy<br/>TABLE]
        TG3[customer_claim_policy_telematics<br/>TABLE]
    end
    
    V1 --> B1
    V2 --> B2
    V2 --> B3
    V3 --> B4
    
    B1 --> T1
    B2 --> T2
    B3 --> T3
    B4 --> T4
    
    T1 --> S1
    T2 --> S2
    T3 --> S3
    T4 --> S4
    
    S1 --> TS1
    S2 --> TS2
    S3 --> TS3
    S4 --> TS4
    
    TS4 --> G1
    TS1 --> G2
    TS2 --> G2
    TS3 --> G2
    
    G1 --> TG1
    G2 --> TG2
    
    TG1 --> G3
    TG2 --> G3
    G3 --> TG3
    
    style V1 fill:#ffcccc
    style V2 fill:#ffcccc
    style V3 fill:#ffcccc
    style T1 fill:#ffe6cc
    style T2 fill:#ffe6cc
    style T3 fill:#ffe6cc
    style T4 fill:#ffe6cc
    style TS1 fill:#ccf2ff
    style TS2 fill:#ccf2ff
    style TS3 fill:#ccf2ff
    style TS4 fill:#ccf2ff
    style TG1 fill:#ccffcc
    style TG2 fill:#ccffcc
    style TG3 fill:#ccffcc
```

## 📁 Estrutura de Diretórios

```
ingest_sql/
├── README.md                    # Este arquivo
├── source_to_bronze/            # Etapa 1: Ingestão (Volumes → Bronze)
│   ├── get_claim.sql            # Ingesta claims.csv → bronze.claim
│   ├── get_customers.sql        # Ingesta customers.csv → bronze.customer
│   ├── get_policies.sql         # Ingesta policies.csv → bronze.policy
│   └── get_telematics.sql       # Ingesta telematics/*.parquet → bronze.telematics
├── bronze_to_silver/            # Etapa 2: Transformação (Bronze → Silver)
│   ├── clean_claim.sql          # Limpa e valida bronze.claim → silver.claim
│   ├── clean_customer.sql       # Limpa bronze.customer → silver.customer
│   ├── clean_policy.sql         # Limpa bronze.policy → silver.policy
│   └── clean_telematics.sql     # Limpa bronze.telematics → silver.telematics
└── silver_to_gold/              # Etapa 3: Agregação (Silver → Gold)
    ├── aggregated_telematics.sql # Agrega silver.telematics → gold.aggregated_telematics
    ├── customer_claim_policy.sql # Join: silver.{claim,policy,customer} → gold.customer_claim_policy
    └── customer_claim_policy_telematics.sql # Join final com telemetria agregada
```

## 🔄 Fluxo de Transformação Detalhado

### Fase 1: source_to_bronze (Ingestão)

```mermaid
flowchart TD
    subgraph "Input: Volumes"
        V1[sql_server/claims.csv]
        V2[sql_server/customers.csv]
        V3[sql_server/policies.csv]
        V4[telematics/*.parquet]
    end
    
    subgraph "Pipeline: source_to_bronze"
        P1[get_claim.sql<br/>cloud_files<br/>+ metadata]
        P2[get_customers.sql<br/>cloud_files<br/>+ metadata]
        P3[get_policies.sql<br/>cloud_files<br/>+ metadata]
        P4[get_telematics.sql<br/>cloud_files<br/>+ metadata]
    end
    
    subgraph "Output: 01_bronze"
        B1[claim<br/>STREAMING TABLE<br/>+ input_file<br/>+ ingested_at]
        B2[customer<br/>STREAMING TABLE<br/>+ input_file<br/>+ ingested_at]
        B3[policy<br/>STREAMING TABLE<br/>+ input_file<br/>+ ingested_at]
        B4[telematics<br/>STREAMING TABLE<br/>+ input_file<br/>+ ingested_at]
    end
    
    V1 --> P1 --> B1
    V2 --> P2 --> B2
    V3 --> P3 --> B3
    V4 --> P4 --> B4
    
    style P1 fill:#ffcccc
    style P2 fill:#ffcccc
    style P3 fill:#ffcccc
    style P4 fill:#ffcccc
    style B1 fill:#ffe6cc
    style B2 fill:#ffe6cc
    style B3 fill:#ffe6cc
    style B4 fill:#ffe6cc
```

**Características:**
- Usa `cloud_files()` para leitura incremental de arquivos
- Adiciona metadados: `input_file`, `input_file_mtime`, `ingested_at`
- Preserva dados brutos imutáveis (append-only)
- Streaming tables para processamento incremental

### Fase 2: bronze_to_silver (Transformação)

```mermaid
flowchart TD
    subgraph "Input: 01_bronze"
        B1[claim<br/>Raw Data]
        B2[customer<br/>Raw Data]
        B3[policy<br/>Raw Data]
        B4[telematics<br/>Raw Data]
    end
    
    subgraph "Transformações"
        T1[clean_claim.sql<br/>- TO_DATE conversions<br/>- Type casting<br/>- Constraints]
        T2[clean_customer.sql<br/>- Date parsing<br/>- TRIM/UPPER<br/>- Validation]
        T3[clean_policy.sql<br/>- Column mapping<br/>- ABS on premium<br/>- Type casting]
        T4[clean_telematics.sql<br/>- Coordinate validation<br/>- Type casting<br/>- Timestamp conversion]
    end
    
    subgraph "Output: 02_silver"
        S1[claim<br/>STREAMING TABLE<br/>Validated & Cleaned]
        S2[customer<br/>STREAMING TABLE<br/>Validated & Cleaned]
        S3[policy<br/>STREAMING TABLE<br/>Validated & Cleaned]
        S4[telematics<br/>STREAMING TABLE<br/>Validated & Cleaned]
    end
    
    B1 --> T1 --> S1
    B2 --> T2 --> S2
    B3 --> T3 --> S3
    B4 --> T4 --> S4
    
    style T1 fill:#ccf2ff
    style T2 fill:#ccf2ff
    style T3 fill:#ccf2ff
    style T4 fill:#ccf2ff
    style S1 fill:#ccf2ff
    style S2 fill:#ccf2ff
    style S3 fill:#ccf2ff
    style S4 fill:#ccf2ff
```

**Transformações Aplicadas:**
- **Claim**: Conversão de datas, validação de horas (0-23), type casting
- **Customer**: Parse de datas, normalização de strings, validação de zip_code
- **Policy**: Mapeamento de colunas, normalização de valores (ABS premium), type casting
- **Telematics**: Validação de coordenadas (lat/long), conversão de timestamps, type casting

### Fase 3: silver_to_gold (Agregação)

```mermaid
flowchart TD
    subgraph "Input: 02_silver"
        S1[claim]
        S2[customer]
        S3[policy]
        S4[telematics]
    end
    
    subgraph "Agregação"
        A1[aggregated_telematics.sql<br/>GROUP BY chassis_no<br/>AVG speed/lat/long]
    end
    
    subgraph "Join"
        J1[customer_claim_policy.sql<br/>claim JOIN policy<br/>JOIN customer]
    end
    
    subgraph "Join Final"
        J2[customer_claim_policy_telematics.sql<br/>customer_claim_policy<br/>LEFT JOIN<br/>aggregated_telematics]
    end
    
    subgraph "Output: 03_gold"
        G1[aggregated_telematics<br/>STREAMING TABLE<br/>Métricas por veículo]
        G2[customer_claim_policy<br/>STREAMING TABLE<br/>Claims unificados]
        G3[customer_claim_policy_telematics<br/>STREAMING TABLE<br/>Dataset completo]
    end
    
    S4 --> A1 --> G1
    S1 --> J1
    S2 --> J1
    S3 --> J1
    J1 --> G2
    
    G1 --> J2
    G2 --> J2
    J2 --> G3
    
    style A1 fill:#ccffcc
    style J1 fill:#ccffcc
    style J2 fill:#ccffcc
    style G1 fill:#ccffcc
    style G2 fill:#ccffcc
    style G3 fill:#ccffcc
```

**Agregações:**
- **aggregated_telematics**: Médias de velocidade, latitude e longitude por `chassis_no`
- **customer_claim_policy**: Join completo de claims com policies e customers
- **customer_claim_policy_telematics**: Dataset final com telemetria agregada

## 🔗 Dependências entre Tabelas

```mermaid
graph LR
    subgraph "Bronze"
        B1[claim]
        B2[customer]
        B3[policy]
        B4[telematics]
    end
    
    subgraph "Silver"
        S1[claim]
        S2[customer]
        S3[policy]
        S4[telematics]
    end
    
    subgraph "Gold"
        G1[aggregated_telematics]
        G2[customer_claim_policy]
        G3[customer_claim_policy_telematics]
    end
    
    B1 --> S1
    B2 --> S2
    B3 --> S3
    B4 --> S4
    
    S4 --> G1
    S1 --> G2
    S2 --> G2
    S3 --> G2
    
    G1 --> G3
    G2 --> G3
    
    style B1 fill:#ffe6cc
    style B2 fill:#ffe6cc
    style B3 fill:#ffe6cc
    style B4 fill:#ffe6cc
    style S1 fill:#ccf2ff
    style S2 fill:#ccf2ff
    style S3 fill:#ccf2ff
    style S4 fill:#ccf2ff
    style G1 fill:#ccffcc
    style G2 fill:#ccffcc
    style G3 fill:#ccffcc
```

## 📋 Detalhamento dos Scripts

### source_to_bronze/

#### `get_claim.sql`
- **Fonte**: `/Volumes/smart_claims_dev/00_landing/sql_server/claims.csv`
- **Destino**: `smart_claims_dev.01_bronze.claim`
- **Tipo**: STREAMING LIVE TABLE
- **Função**: Ingesta dados brutos de sinistros preservando estrutura original

#### `get_customers.sql`
- **Fonte**: `/Volumes/smart_claims_dev/00_landing/sql_server/customers.csv`
- **Destino**: `smart_claims_dev.01_bronze.customer`
- **Tipo**: STREAMING LIVE TABLE
- **Função**: Ingesta dados brutos de clientes preservando estrutura original

#### `get_policies.sql`
- **Fonte**: `/Volumes/smart_claims_dev/00_landing/sql_server/policies.csv`
- **Destino**: `smart_claims_dev.01_bronze.policy`
- **Tipo**: STREAMING LIVE TABLE
- **Função**: Ingesta dados brutos de apólices preservando estrutura original

#### `get_telematics.sql`
- **Fonte**: `/Volumes/smart_claims_dev/00_landing/telematics/*.parquet`
- **Destino**: `smart_claims_dev.01_bronze.telematics`
- **Tipo**: STREAMING LIVE TABLE
- **Função**: Ingesta dados brutos de telemetria veicular

### bronze_to_silver/

#### `clean_claim.sql`
- **Fonte**: `smart_claims_dev.01_bronze.claim`
- **Destino**: `smart_claims_dev.02_silver.claim`
- **Tipo**: STREAMING TABLE
- **Transformações**:
  - Conversão de datas: `TO_DATE(claim_date)`, `TO_DATE(incident_date)`
  - Type casting: `BIGINT`, `INT`, `DOUBLE`, `BOOLEAN`
  - Constraints: `valid_claim_number`, `valid_incident_hour`

#### `clean_customer.sql`
- **Fonte**: `smart_claims_dev.01_bronze.customer`
- **Destino**: `smart_claims_dev.02_silver.customer`
- **Tipo**: STREAMING TABLE
- **Transformações**:
  - Parse de data: `TO_DATE(date_of_birth, 'dd-MM-yyyy')`
  - Normalização: `UPPER(TRIM(borough))`, `TRIM(neighborhood)`
  - Constraints: `valid_customer_id`, `valid_zip_code`

#### `clean_policy.sql`
- **Fonte**: `smart_claims_dev.01_bronze.policy`
- **Destino**: `smart_claims_dev.02_silver.policy`
- **Tipo**: STREAMING TABLE
- **Transformações**:
  - Mapeamento de colunas: `POLICY_NO` → `policy_no`
  - Normalização: `ABS(CAST(PREMIUM AS DOUBLE))`
  - Conversões de data: `TO_DATE(POL_ISSUE_DATE)`, etc.
  - Constraints: `valid_policy_no`

#### `clean_telematics.sql`
- **Fonte**: `smart_claims_dev.01_bronze.telematics`
- **Destino**: `smart_claims_dev.02_silver.telematics`
- **Tipo**: STREAMING TABLE
- **Transformações**:
  - Type casting: `DOUBLE`, `TIMESTAMP`, `STRING`
  - Constraints: `valid_coordinates` (latitude -90 a 90, longitude -180 a 180)

### silver_to_gold/

#### `aggregated_telematics.sql`
- **Fonte**: `smart_claims_dev.02_silver.telematics`
- **Destino**: `smart_claims_dev.03_gold.aggregated_telematics`
- **Tipo**: STREAMING TABLE
- **Agregações**:
  - `AVG(speed)` → `telematics_speed`
  - `AVG(latitude)` → `telematics_latitude`
  - `AVG(longitude)` → `telematics_longitude`
  - `COUNT(*)` → `telematics_event_count`
  - `MIN/MAX(event_timestamp)` → timestamps de primeira/última ocorrência

#### `customer_claim_policy.sql`

- **Fontes**:
  - `smart_claims_dev.02_silver.claim`
  - `smart_claims_dev.02_silver.policy`
  - `smart_claims_dev.02_silver.customer`
- **Destino**: `smart_claims_dev.03_gold.customer_claim_policy`
- **Tipo**: STREAMING TABLE
- **Joins**:
  - `claim JOIN policy ON policy_no`
  - Resultado `JOIN customer ON cust_id = customer_id`
- **Campos adicionais**: Campo `address` construído para geocoding futuro

#### `customer_claim_policy_telematics.sql`

- **Fontes**:
  - `smart_claims_dev.03_gold.customer_claim_policy`
  - `smart_claims_dev.03_gold.aggregated_telematics`
- **Destino**: `smart_claims_dev.03_gold.customer_claim_policy_telematics`
- **Tipo**: STREAMING TABLE
- **Join**: `LEFT JOIN aggregated_telematics ON chassis_no`
- **Constraint**: `valid_borough EXPECT (borough IS NOT NULL)`
- **Campos adicionais**: `geocoded_latitude`, `geocoded_longitude` (NULL, para preenchimento futuro)

## 🚀 Como Executar

### Opção 1: Delta Live Tables Pipeline

1. **Criar Pipeline no Databricks:**
   - Vá em **Delta Live Tables** → **Create Pipeline**
   - Configure a pasta `ingest_sql` como source
   - Selecione o catálogo de destino: `smart_claims_dev`

2. **Executar Pipeline:**
   - Clique em **Start** para executar o pipeline completo
   - Ou use **Run file** para executar um script individual

3. **Monitorar Execução:**
   - Acompanhe progresso na interface do pipeline
   - Verifique logs e métricas de qualidade de dados

### Opção 2: Execução Manual

Execute os scripts na ordem:

```bash
# 1. source_to_bronze
source_to_bronze/get_claim.sql
source_to_bronze/get_customers.sql
source_to_bronze/get_policies.sql
source_to_bronze/get_telematics.sql

# 2. bronze_to_silver
bronze_to_silver/clean_claim.sql
bronze_to_silver/clean_customer.sql
bronze_to_silver/clean_policy.sql
bronze_to_silver/clean_telematics.sql

# 3. silver_to_gold
silver_to_gold/aggregated_telematics.sql
silver_to_gold/customer_claim_policy.sql
silver_to_gold/customer_claim_policy_telematics.sql
```

## ✅ Validação e Qualidade de Dados

Todos os scripts incluem:

- **Constraints**: Validação de dados (NOT NULL, ranges, formatos)
- **Type Safety**: Conversões explícitas de tipos
- **Metadata**: Rastreabilidade com `input_file`, `ingested_at`, `joined_at`
- **Streaming**: Processamento incremental para eficiência
- **Idempotência**: Uso de `CREATE OR REFRESH` para reexecução segura

## 📚 Recursos Adicionais

- [Documentação Delta Live Tables](https://docs.databricks.com/dlt/)
- [Unity Catalog Guide](https://docs.databricks.com/data-governance/unity-catalog/)
- [Medallion Architecture](https://www.databricks.com/glossary/medallion-architecture)

---

**Última atualização**: Todos os pipelines estão implementados e prontos para execução em produção.
