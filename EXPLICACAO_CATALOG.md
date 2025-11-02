# Explicação dos Comandos de Catalog no Databricks Unity Catalog

## Visão Geral

O **Unity Catalog** (Lakeflow) é o sistema de governança de dados unificada do Databricks. Ele fornece uma camada de abstração sobre os dados, permitindo governança, segurança e descoberta de dados em toda a organização.

## Hierarquia de Objetos

```
CATALOG (Catálogo)
  └── SCHEMA (Schema/Database)
      └── TABLE/VIEW (Tabela/Visualização)
          └── COLUMN (Coluna)
```

## Comandos Principais

### 1. CREATE CATALOG

**Sintaxe:**
```sql
CREATE CATALOG [IF NOT EXISTS] catalog_name
[COMMENT 'comentário']
[WITH (DBPROPERTIES (...))]
```

**O que faz:**
- Cria um novo catálogo no Unity Catalog
- Um catálogo é o container de nível mais alto que agrupa schemas relacionados
- Permite isolamento lógico de dados por projeto, ambiente ou domínio
- Suporta propriedades customizadas (DBPROPERTIES) para metadados
- Pode ser compartilhado entre múltiplos workspaces do Databricks

**Exemplo:**
```sql
CREATE CATALOG smart_claims_dev
COMMENT 'Catálogo para projeto Smart Claims'
WITH (DBPROPERTIES ('environment' = 'dev'));
```

---

### 2. USE CATALOG

**Sintaxe:**
```sql
USE CATALOG catalog_name;
```

**O que faz:**
- Define o catálogo ativo para a sessão atual
- Todos os comandos subsequentes trabalharão neste catálogo
- Similar ao `USE DATABASE` em sistemas SQL tradicionais

**Exemplo:**
```sql
USE CATALOG smart_claims_dev;
```

---

### 3. CREATE SCHEMA

**Sintaxe:**
```sql
CREATE SCHEMA [IF NOT EXISTS] catalog_name.schema_name
[COMMENT 'comentário']
[WITH (DBPROPERTIES (...))]
```

**O que faz:**
- Cria um schema (também chamado de database) dentro de um catálogo
- Schemas organizam tabelas relacionadas logicamente
- Cada schema pode ter suas próprias configurações de propriedades
- Suporta nomes com caracteres especiais (usar backticks: `` `schema_name` ``)

**Exemplo:**
```sql
CREATE SCHEMA smart_claims_dev.`01_bronze`
COMMENT 'Camada bronze para dados brutos';
```

---

### 4. SHOW CATALOGS

**Sintaxe:**
```sql
SHOW CATALOGS [LIKE 'pattern'];
```

**O que faz:**
- Lista todos os catálogos visíveis para o usuário atual
- Mostra informações básicas: nome, tipo, propriedades
- O parâmetro `LIKE` permite filtrar por padrão de nome
- Útil para verificar permissões e descobrir catálogos disponíveis

**Exemplo:**
```sql
SHOW CATALOGS LIKE 'smart_claims*';
```

---

### 5. SHOW SCHEMAS

**Sintaxe:**
```sql
SHOW SCHEMAS [IN CATALOG catalog_name] [LIKE 'pattern'];
```

**O que faz:**
- Lista todos os schemas dentro de um catálogo
- Mostra nome, tipo (MANAGED/EXTERNAL), localização, etc.
- Se usado sem `IN CATALOG`, lista schemas do catálogo atual
- Útil para explorar a estrutura de um catálogo

**Exemplo:**
```sql
SHOW SCHEMAS IN CATALOG smart_claims_dev;
```

---

### 6. DESCRIBE CATALOG

**Sintaxe:**
```sql
DESCRIBE CATALOG [EXTENDED] catalog_name;
```

**O que faz:**
- Mostra informações detalhadas sobre um catálogo específico
- Exibe propriedades, comentários, metadados
- A opção `EXTENDED` mostra informações adicionais
- Útil para documentação e auditoria

**Exemplo:**
```sql
DESCRIBE CATALOG smart_claims_dev;
```

---

### 7. DESCRIBE SCHEMA

**Sintaxe:**
```sql
DESCRIBE SCHEMA [EXTENDED] catalog_name.schema_name;
```

**O que faz:**
- Mostra informações detalhadas sobre um schema específico
- Exibe propriedades, comentários, localização, tipo
- Útil para entender configurações de cada camada de dados

**Exemplo:**
```sql
DESCRIBE SCHEMA smart_claims_dev.`01_bronze`;
```

---

### 8. ALTER CATALOG

**Sintaxe:**
```sql
ALTER CATALOG catalog_name SET COMMENT 'novo comentário';
ALTER CATALOG catalog_name SET DBPROPERTIES ('key' = 'value');
```

**O que faz:**
- Modifica propriedades de um catálogo existente
- Permite atualizar comentários e propriedades customizadas
- Útil para manutenção e atualização de metadados

**Exemplo:**
```sql
ALTER CATALOG smart_claims_dev 
SET COMMENT 'Catálogo atualizado em 2024';
```

---

### 9. DROP CATALOG

**Sintaxe:**
```sql
DROP CATALOG [IF EXISTS] catalog_name [CASCADE];
```

**O que faz:**
- Remove um catálogo e todos os seus objetos (schemas, tabelas, etc.)
- Requer `CASCADE` se o catálogo contém objetos
- **CUIDADO**: Operação destrutiva e irreversível!

**Exemplo:**
```sql
DROP CATALOG smart_claims_dev CASCADE;
```

---

## Padrão Medallion Architecture (Lakehouse)

O projeto segue o padrão **Medallion Architecture**, uma arquitetura em camadas:

### 00_landing (Landing Zone)
- **Propósito**: Recepção inicial de dados brutos
- **Retenção**: Curta (ex: 7 dias)
- **Formato**: Geralmente RAW (JSON, CSV, etc.)
- **Características**: Dados transitórios, podem ser deletados após processamento

### 01_bronze (Bronze Layer)
- **Propósito**: Preservação imutável dos dados originais
- **Retenção**: Longa (ex: 1-2 anos)
- **Formato**: Delta Lake (otimizado)
- **Características**: Append-only, mantém histórico completo

### 02_silver (Silver Layer)
- **Propósito**: Dados limpos, validados e enriquecidos
- **Retenção**: Média-Longa (ex: 2-5 anos)
- **Formato**: Delta Lake com schema definido
- **Características**: Dados curados, prontos para consumo

### 03_gold (Gold Layer)
- **Propósito**: Dados agregados e modelados para consumo final
- **Retenção**: Muito longa (ex: 7+ anos)
- **Formato**: Delta Lake otimizado (Z-Order, Partitions)
- **Características**: Otimizado para consultas específicas (star schema, etc.)

---

## Benefícios do Unity Catalog

1. **Governança Unificada**: Gerenciamento centralizado de metadados
2. **Segurança Granular**: Permissões em nível de catálogo, schema, tabela e coluna
3. **Descoberta de Dados**: Catálogo de dados explorável
4. **Auditoria**: Rastreamento de acesso e mudanças
5. **Linhagem**: Rastreamento de origem e transformação dos dados
6. **Compartilhamento**: Compartilhe catálogos entre workspaces/organizações

---

## Próximos Passos

Após criar a estrutura básica:

1. **Criar Tabelas**: Definir tabelas em cada camada
2. **Configurar Permissões**: Definir acesso por role/user
3. **Configurar Políticas**: Definir políticas de retenção e acesso
4. **Ingestão de Dados**: Configurar pipelines para cada camada
5. **Monitoramento**: Configurar alertas e métricas

