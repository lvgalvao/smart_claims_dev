# Smart Claims - Projeto Databricks

## 📋 Sobre o Projeto

**Smart Claims** é um projeto de análise e processamento de sinistros (claims) utilizando a plataforma **Databricks** e a arquitetura moderna de **Lakehouse** com **Unity Catalog** (Lakeflow). O projeto implementa o padrão **Medallion Architecture** para garantir qualidade, rastreabilidade e governança de dados.

### Objetivos do Projeto

- Processar e analisar dados de sinistros de forma eficiente e escalável
- Implementar governança de dados com Unity Catalog
- Criar uma arquitetura de dados em camadas (Landing → Bronze → Silver → Gold)
- Facilitar análises, relatórios e modelos de Machine Learning sobre sinistros

---

## 🏗️ Arquitetura de Dados

O projeto segue o padrão **Medallion Architecture**, organizando dados em camadas progressivas:

```text
smart_claims_dev (CATALOG)
│
├── 00_landing       → Zona de recepção de dados brutos
├── 01_bronze        → Dados brutos preservados imutavelmente
├── 02_silver        → Dados limpos, validados e enriquecidos
├── 03_gold          → Dados agregados e modelados para consumo
├── default          → Schema padrão para objetos diversos
└── information_schema → Metadados do sistema
```

### Descrição das Camadas

| Camada | Propósito | Retenção | Formato |
|--------|-----------|----------|---------|
| **00_landing** | Recepção inicial de dados de sistemas externos | 7 dias | RAW (JSON, CSV, Parquet) |
| **01_bronze** | Preservação imutável dos dados originais | 365 dias | Delta Lake (append-only) |
| **02_silver** | Dados limpos, validados e enriquecidos | 730 dias | Delta Lake (schema definido) |
| **03_gold** | Dados agregados e otimizados para consumo final | 2555 dias | Delta Lake (otimizado, particionado) |

---

## 📁 Estrutura do Repositório

```text
smart_claims_dev/
├── README.md                           # Este arquivo
├── EXPLICACAO_CATALOG.md               # Documentação detalhada sobre Unity Catalog
├── 01_create_catalog_and_schemas.sql   # Script SQL para criação do catálogo e schemas
└── data/
    └── example/                        # Exemplos de dados (se aplicável)
```

---

## ✅ Task_001 - Criação do Catálogo e Schemas

### Objetivo

Criar a estrutura base do projeto no Databricks utilizando **Unity Catalog**, incluindo o catálogo principal e todos os schemas necessários para implementar a arquitetura Medallion.

### O que foi Implementado

#### 1. **Criação do Catálogo `smart_claims_dev`**

Foi criado um catálogo completo no Unity Catalog com as seguintes características:

```sql
CREATE CATALOG IF NOT EXISTS smart_claims_dev
COMMENT 'Catálogo principal para o projeto Smart Claims - Ambiente de Desenvolvimento'
WITH (
  DBPROPERTIES (
    'project' = 'smart_claims',
    'environment' = 'dev',
    'created_by' = 'databricks_admin',
    'created_date' = current_date()
  )
);
```

**Exemplos concretos do que isso proporciona:**

- ✅ Isolamento lógico de todos os dados do projeto Smart Claims
- ✅ Metadados customizados para rastreabilidade (project, environment, created_by, created_date)
- ✅ Base para compartilhamento entre workspaces/organizações
- ✅ Governança centralizada de permissões e políticas

#### 2. **Criação dos 6 Schemas**

Cada schema foi criado com propriedades específicas e comentários descritivos:

##### **00_landing** - Zona de Recepção

```sql
CREATE SCHEMA IF NOT EXISTS smart_claims_dev.`00_landing`
COMMENT 'Zona de landing - recepção de dados brutos de sistemas externos'
WITH (
  DBPROPERTIES (
    'layer' = 'landing',
    'retention_days' = '7',
    'purpose' = 'Armazenamento temporário de dados brutos antes do processamento'
  )
);
```

**Exemplo de uso:** Tabelas como `raw_claims_api`, `raw_policies_export`, `raw_customer_data` receberiam dados diretamente de APIs ou sistemas externos.

##### **01_bronze** - Preservação de Dados Brutos

```sql
CREATE SCHEMA IF NOT EXISTS smart_claims_dev.`01_bronze`
COMMENT 'Camada Bronze - dados brutos preservados de forma imutável'
WITH (
  DBPROPERTIES (
    'layer' = 'bronze',
    'retention_days' = '365',
    'purpose' = 'Armazenamento permanente de dados brutos para auditoria e reprocessamento'
  )
);
```

**Exemplo de uso:** Tabelas como `bronze.claims_raw`, `bronze.policies_raw`, `bronze.customers_raw` manteriam uma cópia imutável de todos os dados originais, permitindo auditoria e reprocessamento histórico.

##### **02_silver** - Dados Curados

```sql
CREATE SCHEMA IF NOT EXISTS smart_claims_dev.`02_silver`
COMMENT 'Camada Silver - dados limpos, validados e enriquecidos'
WITH (
  DBPROPERTIES (
    'layer' = 'silver',
    'retention_days' = '730',
    'purpose' = 'Dados curados e prontos para consumo analítico e operacional'
  )
);
```

**Exemplo de uso:** Tabelas como `silver.claims_clean`, `silver.claims_enriched`, `silver.customers_master` conteriam dados após:

- Validação de tipos e formatos
- Remoção de duplicatas
- Enriquecimento com dados de referência
- Normalização de estruturas

##### **03_gold** - Dados para Consumo Final

```sql
CREATE SCHEMA IF NOT EXISTS smart_claims_dev.`03_gold`
COMMENT 'Camada Gold - dados agregados e modelados para consumo final'
WITH (
  DBPROPERTIES (
    'layer' = 'gold',
    'retention_days' = '2555',
    'purpose' = 'Dados agregados e otimizados para dashboards, relatórios e ML'
  )
);
```

**Exemplo de uso:** Tabelas como `gold.claims_by_month`, `gold.claims_summary`, `gold.customer_claims_facts` seriam otimizadas para:

- Dashboards executivos
- Modelos de Machine Learning
- Relatórios analíticos
- Star schemas para BI tools

##### **default** - Schema Padrão

Schema padrão do catálogo para objetos que não requerem organização específica por camada.

##### **information_schema** - Metadados do Sistema

Schema automático do Unity Catalog que contém metadados sobre todos os objetos do catálogo (tabelas, views, funções, etc.).

#### 3. **Comandos de Verificação Incluídos**

O script também inclui comandos para validação da estrutura criada:

```sql
-- Listar catálogos
SHOW CATALOGS LIKE 'smart_claims*';

-- Listar schemas
SHOW SCHEMAS IN CATALOG smart_claims_dev;

-- Descrever catálogo e schemas
DESCRIBE CATALOG smart_claims_dev;
DESCRIBE SCHEMA smart_claims_dev.`01_bronze`;
```

### Arquivos Gerados

1. **`01_create_catalog_and_schemas.sql`**
   - Script SQL completo e idempotente (pode ser executado múltiplas vezes)
   - Comentários detalhados explicando cada comando
   - Comandos de verificação incluídos
   - Pronto para execução no Databricks Notebook

2. **`EXPLICACAO_CATALOG.md`**
   - Documentação completa sobre Unity Catalog
   - Explicação detalhada de cada comando SQL
   - Descrição da Medallion Architecture
   - Guia de melhores práticas

### Como Executar

1. Abra o Databricks Workspace
2. Crie um novo notebook SQL
3. Copie e cole o conteúdo de `01_create_catalog_and_schemas.sql`
4. Execute todas as células sequencialmente
5. Verifique os resultados usando os comandos `SHOW` e `DESCRIBE`

### Resultado Esperado

Após a execução bem-sucedida, você terá:

- ✅ 1 catálogo criado: `smart_claims_dev`
- ✅ 6 schemas criados dentro do catálogo
- ✅ Estrutura completa para iniciar ingestão de dados
- ✅ Base sólida para implementar pipelines de dados
- ✅ Governança de dados configurada com Unity Catalog

### Próximos Passos

Após concluir a Task_001, as próximas etapas incluem:

- **Task_002**: Criar tabelas de exemplo em cada camada
- **Task_003**: Configurar permissões e roles (data engineers, analysts, etc.)
- **Task_004**: Implementar pipelines de ingestão (Landing → Bronze)
- **Task_005**: Criar transformações (Bronze → Silver → Gold)
- **Task_006**: Configurar monitoramento e alertas

---

## 📚 Documentação Adicional

Para mais detalhes sobre comandos de Catalog e Unity Catalog, consulte:

- [`EXPLICACAO_CATALOG.md`](EXPLICACAO_CATALOG.md) - Documentação completa sobre Unity Catalog

---

## 🛠️ Tecnologias Utilizadas

- **Databricks** - Plataforma de analytics e processamento de dados
- **Unity Catalog** (Lakeflow) - Sistema de governança de dados unificada
- **Delta Lake** - Formato de armazenamento transacional em lakehouse
- **SQL** - Linguagem para criação e manipulação de objetos

---

## 📝 Notas

- Todos os scripts SQL são **idempotentes** (usam `IF NOT EXISTS`), podendo ser executados múltiplas vezes sem erro
- O projeto está configurado para ambiente de **desenvolvimento** (`dev`)
- A estrutura pode ser replicada para outros ambientes (staging, prod) ajustando o nome do catálogo

---

## 👥 Contribuição

Este é um projeto em desenvolvimento. Para contribuir:

1. Siga o padrão de nomenclatura estabelecido
2. Mantenha a documentação atualizada
3. Teste scripts em ambiente de dev antes de produção
