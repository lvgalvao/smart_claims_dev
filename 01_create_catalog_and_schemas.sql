-- ============================================================
-- CRIÇÃO DO CATÁLOGO E SCHEMAS - SMART CLAIMS DEV
-- Usando Unity Catalog (Lakeflow) - Databricks
-- ============================================================

-- ============================================================
-- PARTE 1: CRIAR O CATÁLOGO
-- ============================================================

-- COMANDO: CREATE CATALOG
-- O que faz:
-- - Cria um novo catálogo no Unity Catalog (sistema de governança de dados do Databricks)
-- - Um catálogo é um container de nível superior que agrupa schemas relacionados
-- - Permite isolamento e organização de dados por projeto/ambiente (dev, prod, etc.)
-- - O catálogo possui permissões próprias e pode ser compartilhado entre workspaces
-- - É o nível mais alto na hierarquia: CATALOG > SCHEMA > TABLE

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

-- Usar o catálogo criado
USE CATALOG smart_claims_dev;


-- ============================================================
-- PARTE 2: CRIAR OS SCHEMAS (DATABASES)
-- ============================================================

-- COMANDO: CREATE SCHEMA
-- O que faz:
-- - Cria um schema (também chamado de database) dentro do catálogo
-- - Schemas organizam tabelas relacionadas logicamente
-- - Cada schema pode ter permissões e políticas de retenção próprias
-- - É o segundo nível na hierarquia: CATALOG > SCHEMA > TABLE

-- Schema 00_landing: Zona de recepção de dados brutos
-- Normalmente recebe dados diretamente de sistemas externos
CREATE SCHEMA IF NOT EXISTS smart_claims_dev.`00_landing`
COMMENT 'Zona de landing - recepção de dados brutos de sistemas externos'
WITH (
  DBPROPERTIES (
    'layer' = 'landing',
    'retention_days' = '7',
    'purpose' = 'Armazenamento temporário de dados brutos antes do processamento'
  )
);

-- Schema 01_bronze: Camada de dados brutos preservados
-- Mantém uma cópia imutável dos dados originais (Data Lake Pattern)
CREATE SCHEMA IF NOT EXISTS smart_claims_dev.`01_bronze`
COMMENT 'Camada Bronze - dados brutos preservados de forma imutável'
WITH (
  DBPROPERTIES (
    'layer' = 'bronze',
    'retention_days' = '365',
    'purpose' = 'Armazenamento permanente de dados brutos para auditoria e reprocessamento'
  )
);

-- Schema 02_silver: Camada de dados limpos e enriquecidos
-- Dados transformados, validados e com qualidade garantida
CREATE SCHEMA IF NOT EXISTS smart_claims_dev.`02_silver`
COMMENT 'Camada Silver - dados limpos, validados e enriquecidos'
WITH (
  DBPROPERTIES (
    'layer' = 'silver',
    'retention_days' = '730',
    'purpose' = 'Dados curados e prontos para consumo analítico e operacional'
  )
);

-- Schema 03_gold: Camada de dados agregados e otimizados
-- Dados agregados, modelados e otimizados para consultas específicas (star schema, etc.)
CREATE SCHEMA IF NOT EXISTS smart_claims_dev.`03_gold`
COMMENT 'Camada Gold - dados agregados e modelados para consumo final'
WITH (
  DBPROPERTIES (
    'layer' = 'gold',
    'retention_days' = '2555',
    'purpose' = 'Dados agregados e otimizados para dashboards, relatórios e ML'
  )
);

-- Schema default: Schema padrão do catálogo
-- Utilizado para objetos que não precisam de organização específica
CREATE SCHEMA IF NOT EXISTS smart_claims_dev.default
COMMENT 'Schema padrão do catálogo smart_claims_dev'
WITH (
  DBPROPERTIES (
    'layer' = 'default',
    'purpose' = 'Schema padrão para objetos diversos'
  )
);

-- Schema information_schema: Schema do sistema
-- Contém metadados sobre objetos do catálogo (tabelas, views, etc.)
-- NOTA: Este schema geralmente é criado automaticamente pelo Unity Catalog
-- Mas vamos garantir que existe
CREATE SCHEMA IF NOT EXISTS smart_claims_dev.information_schema
COMMENT 'Schema do sistema - contém metadados do catálogo'
WITH (
  DBPROPERTIES (
    'layer' = 'system',
    'purpose' = 'Metadados e informações do catálogo (gerenciado pelo Unity Catalog)'
  )
);


-- ============================================================
-- PARTE 3: VERIFICAÇÃO E CONSULTA DOS OBJETOS CRIADOS
-- ============================================================

-- COMANDO: SHOW CATALOGS
-- O que faz:
-- - Lista todos os catálogos visíveis para o usuário atual
-- - Mostra metadados básicos dos catálogos
-- - Útil para verificar permissões e catálogos disponíveis

SHOW CATALOGS LIKE 'smart_claims*';


-- COMANDO: SHOW SCHEMAS
-- O que faz:
-- - Lista todos os schemas dentro do catálogo atual
-- - Mostra nome, tipo (MANAGED/EXTERNAL), localização, etc.
-- - Útil para verificar a estrutura criada

SHOW SCHEMAS IN CATALOG smart_claims_dev;


-- COMANDO: DESCRIBE CATALOG
-- O que faz:
-- - Mostra informações detalhadas sobre um catálogo específico
-- - Exibe propriedades, comentários, e metadados
-- - Útil para documentação e auditoria

DESCRIBE CATALOG smart_claims_dev;


-- COMANDO: DESCRIBE SCHEMA
-- O que faz:
-- - Mostra informações detalhadas sobre um schema específico
-- - Exibe propriedades, comentários, localização, e metadados
-- - Útil para entender a configuração de cada camada

DESCRIBE SCHEMA smart_claims_dev.`00_landing`;
DESCRIBE SCHEMA smart_claims_dev.`01_bronze`;
DESCRIBE SCHEMA smart_claims_dev.`02_silver`;
DESCRIBE SCHEMA smart_claims_dev.`03_gold`;


-- ============================================================
-- PARTE 4: CONFIGURAÇÕES ADICIONAIS (OPCIONAL)
-- ============================================================

-- COMANDO: ALTER CATALOG
-- O que faz:
-- - Modifica propriedades de um catálogo existente
-- - Permite atualizar comentários, propriedades, etc.
-- - Útil para manutenção e atualização de metadados

-- Exemplo de atualização de comentário (opcional)
-- ALTER CATALOG smart_claims_dev SET COMMENT 'Catálogo atualizado em ' || current_timestamp();


-- COMANDO: GRANT/REVOKE
-- O que faz:
-- - Gerencia permissões em catálogos e schemas
-- - Permite controle de acesso granular
-- - Essencial para segurança e governança

-- Exemplo de permissões (ajustar conforme necessário):
-- GRANT USE CATALOG ON CATALOG smart_claims_dev TO `data_engineers`;
-- GRANT CREATE SCHEMA ON CATALOG smart_claims_dev TO `data_engineers`;
-- GRANT ALL PRIVILEGES ON SCHEMA smart_claims_dev.`00_landing` TO `data_engineers`;


-- ============================================================
-- RESUMO DA ESTRUTURA CRIADA
-- ============================================================
-- 
-- CATALOG: smart_claims_dev
--   ├── SCHEMA: 00_landing      (Zona de recepção)
--   ├── SCHEMA: 01_bronze        (Dados brutos imutáveis)
--   ├── SCHEMA: 02_silver        (Dados limpos e curados)
--   ├── SCHEMA: 03_gold          (Dados agregados e modelados)
--   ├── SCHEMA: default          (Schema padrão)
--   └── SCHEMA: information_schema (Metadados do sistema)
-- 
-- ============================================================

