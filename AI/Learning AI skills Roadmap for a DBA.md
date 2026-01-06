# **Learning AI skills Roadmap for a DBA**

**Phase 1: AI Foundations (Jan-Feb 2026)**

**Goal:** Understand AI concepts and use cases for DBAs.  
**Topics:** AI vs ML vs DL, supervised vs unsupervised learning, embeddings.  
**Sample Project:**

- Create a simple classification model in Excel or Python to predict query performance category (fast/slow) using sample data.  
    **Free Resources:**
- <https://learn.microsoft.com/en-us/training/paths/introduction-to-ai/>
- <https://www.coursera.org/learn/ai-for-everyone>

**Phase 2: SQL Server AI Features (Mar-Apr 2026)**

**Goal:** Use built-in AI capabilities in SQL Server.  
**Topics:** Query Store, Automatic Tuning, Machine Learning Services, SQL Server 2025 AI (Vector Search).  
**Sample Project:**

- Enable Query Store and run Python anomaly detection inside SQL Server using sp_execute_external_script.  
    **Free Resources:**
- <https://learn.microsoft.com/en-us/sql/machine-learning/>
- <https://learn.microsoft.com/en-us/training/modules/intelligent-query-processing/>

**Phase 3: Python for AI Integration (May-Jun 2026)**

**Goal:** Minimal coding for AI tasks.  
**Topics:** Pandas, Scikit-learn basics, API calls.  
**Sample Project:**

- Build an IsolationForest anomaly detector for slow queries using Python inside SQL Server.  
    **Free Resources:**
- <https://www.kaggle.com/learn/python>
- <https://learn.microsoft.com/en-us/sql/machine-learning/tutorials/>

**Phase 4: Azure AI & OpenAI Integration (Jul-Aug 2026)**

**Goal:** Use cloud AI services with SQL Server.  
**Topics:** Cognitive Services, Azure OpenAI, Retrieval-Augmented Generation (RAG).  
**Sample Project:**

- Create a chatbot that answers SQL performance questions using Azure OpenAI and Query Store data.  
    **Free Resources:**
- <https://learn.microsoft.com/en-us/training/paths/azure-ai-fundamentals/>
- <https://learn.microsoft.com/en-us/azure/ai-services/openai/>

**Phase 5: Big Data AI with Databricks (Sep-Oct 2026)**

**Goal:** Apply AI to large-scale data.  
**Topics:** AutoML, MLflow, Generative AI in Databricks.  
**Sample Project:**

- Predict resource utilization trends using Databricks AutoML on historical workload data.  
    **Free Resources:**
- <https://academy.databricks.com/>
- <https://learn.microsoft.com/en-us/training/paths/data-engineer-azure-databricks/>

**Phase 6: Advanced Integration & Automation (Nov-Dec 2026)**

**Goal:** Automate AI-driven insights for DBA tasks.  
**Topics:** AI-powered monitoring, natural language dashboards, AI in ETL pipelines.  
**Sample Project:**

- Automate predictive alerts for disk space and performance issues using Azure Monitor anomaly detection.  
    **Free Resources:**
- <https://learn.microsoft.com/en-us/training/>

**Key Skills Summary**

- Conceptual: AI basics, embeddings, RAG.
- Technical: T-SQL for AI features, Python for integration.
- Cloud: Azure AI, OpenAI, Databricks AutoML.
- Practical: Performance tuning, anomaly detection, forecasting.

**Phase 2: SQL Server AI Features (Mar-Apr 2026)**

**Goal:** Use built-in AI capabilities in SQL Server for performance tuning and anomaly detection.

**Step 1: Enable Query Store**

Query Store is the foundation for automatic tuning and performance insights.

ALTER DATABASE \[YourDB\] SET QUERY_STORE = ON;_

_ALTER DATABASE \[YourDB\] SET QUERY_STORE (OPERATION_MODE = READ_WRITE);

**Why?**

- Captures query execution history, plans, and runtime stats.
- Required for Automatic Plan Correction and Query Store hints.

**Step 2: Turn On Automatic Plan Correction**

This feature automatically forces the last known good plan when regressions occur.

ALTER DATABASE \[YourDB\]

SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = ON);

**Benefits:**

- Detects plan regressions.
- Applies fixes automatically and validates improvements.

**Step 3: Use Query Store Hints (No App Code Changes)**

Apply hints to problematic queries without modifying application SQL.

EXEC sys.sp_query_store_set_hints

&nbsp;   @query_id = 12345,

&nbsp;   @hint = N'OPTION (MAXDOP 4)';

To remove:

EXEC sys.sp_query_store_remove_hints @query_id = 12345;

**Step 4: Enable Machine Learning Services**

Run Python scripts inside SQL Server for anomaly detection.

EXEC sp_configure 'external scripts enabled', 1;

RECONFIGURE;

**Step 5: Sample AI Project - Anomaly Detection**

Detect slow queries using Python IsolationForest inside SQL Server.

DECLARE @py NVARCHAR(MAX) = N'

import pandas as pd

from sklearn.ensemble import IsolationForest

df = InputDataSet.copy()

model = IsolationForest(contamination=0.02, random_state=42)_

_df\["anomaly"\] = model.fit_predict(df\[\["avg_duration_ms","avg_cpu_ms","avg_reads"\]\])_

_OutputDataSet = df\[df\["anomaly"\]==-1\]_

_';_

_EXEC sp_execute_external_script

&nbsp; @language = N'Python',

&nbsp; @script = @py,

&nbsp; @input_data_1 = N'

&nbsp;   SELECT TOP (1000)

&nbsp;     qs.query_id,_

&nbsp;     _rs.avg_duration AS avg_duration_ms,

&nbsp;     rs.avg_cpu_time AS avg_cpu_ms,

&nbsp;     rs.avg_logical_io_reads AS avg_reads

&nbsp;   FROM sys.query_store_runtime_stats rs_

&nbsp;   _JOIN sys.query_store_plan qp ON rs.plan_id = qp.plan_id_

&nbsp;   _JOIN sys.query_store_query qs ON qp.query_id = qs.query_id_

&nbsp;   _ORDER BY rs.last_execution_time DESC;',_

&nbsp; _@output_data_1_name = N'OutputDataSet';

**Step 6: Explore SQL Server 2025 AI Features**

- **Vector Search**: Store embeddings and perform semantic queries.
- **External Models**: Call Azure OpenAI directly from T-SQL.

Example:

CREATE EXTERNAL MODEL MyOpenAIModel

WITH (LOCATION = '<https://api.openai.azure.com/…>', AUTHENTICATION = 'ManagedIdentity');

**Free Resources**

- <https://learn.microsoft.com/en-us/training/modules/intelligent-query-processing/>
- <https://learn.microsoft.com/en-us/sql/machine-learning/>
- [Automatic Tuning in Azure SQL](https://learn.microsoft.com/en-us/azure/azure-sql/database/automatic-tuning-overview?view=azuresql)

**VECTOR_SEARCH**

**1) Prerequisites**

- SQL Server **2025 (17.x)** build with **vector features** enabled.
- **SSMS 21** or later for full client support. [\[azurelessons.com\]](https://azurelessons.com/azure-cognitive-services-tutorial/)
- An embedding provider (e.g., **Azure OpenAI** or **Ollama**) you can register via CREATE EXTERNAL MODEL. [\[hugobarona.com\]](https://www.hugobarona.com/optimizing-your-sql-database-workloads-with-automatic-tuning-on-azure/)

**2) Create a table with a VECTOR(n) column**

Pick a dimension size n that matches your embedding model (e.g., 384, 512, 768).

USE YourDb;

\-- Store product catalog items with embeddings

CREATE TABLE dbo.Products (

&nbsp;   ProductId     INT            NOT NULL PRIMARY KEY,

&nbsp;   Title         NVARCHAR(200)  NOT NULL,

&nbsp;   Description   NVARCHAR(MAX)  NULL,

&nbsp;   Embedding     VECTOR(768)    NULL,   -- choose the right dimension for your model

&nbsp;   ModifiedAt    DATETIME2(7)   DEFAULT SYSUTCDATETIME()

);

\`\`

**Why this works**: SQL Server 2025 introduces a native vector data type that stores dense arrays and supports similarity operations. [\[hugobarona.com\]](https://www.hugobarona.com/optimizing-your-sql-database-workloads-with-automatic-tuning-on-azure/)

**3) Create a DiskANN vector index (required for VECTOR_SEARCH)**

VECTOR_SEARCH uses an ANN index for speed. Without it, you can only use VECTOR_DISTANCE (exact K‑NN) which scales poorly on large sets.

\-- Create a DiskANN vector index on the embedding column

CREATE VECTOR INDEX IX_Products_Embedding

ON dbo.Products(Embedding)

USING DISKANN;  -- ANN structure optimized for SSDs and low memory

**Notes**

- DiskANN backs the fast ANN queries with high recall (≈0.95 typical) while keeping resource use modest. [\[axial-sql.com\]](https://axial-sql.com/building-intelligent-applications-with-sql-server-and-azure-cognitive-services/)
- Index build time depends on row count and dimension; expect background I/O during build.

**4) Register an external embedding model**

You can reference a hosted API (Azure OpenAI, Ollama behind TLS, etc.) and call it directly from T‑SQL to generate embeddings.

\-- Register an external model endpoint that produces embeddings

\-- Replace ENDPOINT and AUTH details with your environment

CREATE EXTERNAL MODEL dbo.Model_Embeddings

WITH (

&nbsp;   ENDPOINT = 'https://&lt;your-embedding-endpoint&gt;',

&nbsp;   AUTHENTICATION = 'ManagedIdentity'   -- or 'ApiKey' depending on provider

);

- The **Learn module** and **Intelligent Applications** docs show using Azure OpenAI via CREATE EXTERNAL MODEL and managed identities. [\[hugobarona.com\]](https://www.hugobarona.com/optimizing-your-sql-database-workloads-with-automatic-tuning-on-azure/), [\[youtube.com\]](https://www.youtube.com/watch?v=oRXylMoL6EM)
- If you prefer **Ollama**, see the FastStart project that wires up SQL Server 2025 + Ollama + SSL and demonstrates model registration and calls.

**5) Populate embeddings**

Use your external model to infer embeddings from text fields.

\-- Generate embeddings for existing rows

UPDATE P

SET Embedding = dbo.Model_Embeddings.INFER(P.Description)

FROM dbo.Products AS P

WHERE P.Embedding IS NULL;

\`\`

You can also embed ad‑hoc text (e.g., a user's query):

DECLARE @query NVARCHAR(MAX) = N'wireless noise-cancelling headphones';

DECLARE @q_vec VECTOR(768) = dbo.Model_Embeddings.INFER(@query);

The Learn module demonstrates embedding generation and using those embeddings for semantic search and RAG. [\[hugobarona.com\]](https://www.hugobarona.com/optimizing-your-sql-database-workloads-with-automatic-tuning-on-azure/)

**6) Run VECTOR_SEARCH: fast ANN nearest neighbors**

Return the **top‑K** nearest neighbors to a query vector, with optional filters.

\-- Find the 10 most semantically similar products for the query text

DECLARE @q NVARCHAR(MAX) = N'wireless noise-cancelling headphones';

DECLARE @q_vec VECTOR(768) = dbo.Model_Embeddings.INFER(@q);

SELECT TOP (10)

&nbsp;   ProductId,

&nbsp;   Title,

&nbsp;   Description,

&nbsp;   -- distance or similarity can be exposed depending on your function semantics

&nbsp;   VECTOR_DISTANCE(Embedding, @q_vec) AS distance

FROM dbo.Products

WHERE VECTOR_SEARCH(Embedding, @q_vec) = 1   -- ANN predicate

ORDER BY distance ASC;                        -- smaller distance = more similar

\`\`

**Key points**

- VECTOR_SEARCH(column, @q_vec) = 1 is the **ANN filter** that leverages the DiskANN index to locate candidates quickly. You then sort with VECTOR_DISTANCE to see the ordering (or use the ranking returned by your implementation). [\[axial-sql.com\]](https://axial-sql.com/building-intelligent-applications-with-sql-server-and-azure-cognitive-services/)
- For **exact** nearest neighbors (K‑NN), skip the index and use VECTOR_DISTANCE across the set-but this is CPU‑heavy at scale. Use exact search mainly for **small collections (<≈50k vectors)** or validation. [\[axial-sql.com\]](https://axial-sql.com/building-intelligent-applications-with-sql-server-and-azure-cognitive-services/)

**7) Combine semantic search with business filters**

You'll often pre‑filter by category, brand, or price before ANN search:

DECLARE @q NVARCHAR(MAX) = N'in‑ear active noise cancellation';

DECLARE @q_vec VECTOR(768) = dbo.Model_Embeddings.INFER(@q);

SELECT TOP (20)

&nbsp;   ProductId, Title, Description,

&nbsp;   VECTOR_DISTANCE(Embedding, @q_vec) AS distance

FROM dbo.Products

WHERE Category = N'Headphones'

&nbsp; AND Price BETWEEN 3000 AND 9000    -- INR example range

&nbsp; AND VECTOR_SEARCH(Embedding, @q_vec) = 1

ORDER BY distance ASC;

Pre‑filtering reduces candidate count and speeds up search, which is recommended in Microsoft guidance. [\[axial-sql.com\]](https://axial-sql.com/building-intelligent-applications-with-sql-server-and-azure-cognitive-services/)

**8) Exact vs Approximate: when to use which**

- **Exact (VECTOR_DISTANCE)**: highest precision. Use for small sets, quality checks, or when accuracy is paramount.
- **Approximate (VECTOR_SEARCH + DiskANN)**: massive speed‑up on large sets. Accept a tiny recall trade‑off for much better latency.\\ Microsoft and field posts recommend **exact under ~50k vectors**; beyond that, **ANN** is preferred. [\[axial-sql.com\]](https://axial-sql.com/building-intelligent-applications-with-sql-server-and-azure-cognitive-services/)

**9) Maintenance and performance tips**

- **Index refresh**: Rebuild the DiskANN index after bulk loads or if you see degraded recall/latency during large updates.
- **Dimension consistency**: Ensure all embeddings in a column share the same dimension.
- **Batch embedding**: Generate embeddings in batches off‑peak; log failures for re‑try.
- **Filter then ANN**: Always apply relational filters before VECTOR_SEARCH. [\[axial-sql.com\]](https://axial-sql.com/building-intelligent-applications-with-sql-server-and-azure-cognitive-services/)
- **Model provenance**: Track which model/version generated the vectors; changing models changes semantic space.
- **Security**: Prefer **Managed Identity** to call Azure OpenAI; store no API keys in T‑SQL when possible. [\[hugobarona.com\]](https://www.hugobarona.com/optimizing-your-sql-database-workloads-with-automatic-tuning-on-azure/)

**10) Full mini‑demo (end‑to‑end)**

USE YourDb;

\-- 1) Table

CREATE TABLE dbo.Docs (

&nbsp;   DocId       INT PRIMARY KEY,

&nbsp;   Title       NVARCHAR(200),

&nbsp;   Body        NVARCHAR(MAX),

&nbsp;   Embedding   VECTOR(384)

);

\-- 2) Index

CREATE VECTOR INDEX IX_Docs_Embedding

ON dbo.Docs(Embedding)

USING DISKANN;

\-- 3) External model (replace with your endpoint/auth)

CREATE EXTERNAL MODEL dbo.Emb384

WITH (ENDPOINT = 'https://&lt;your-embedding-endpoint&gt;', AUTHENTICATION = 'ManagedIdentity');

\-- 4) Populate

INSERT INTO dbo.Docs (DocId, Title, Body)

VALUES (1, N'AG Conditions', N'Always On AG network and failover notes…'),

&nbsp;      (2, N'Indexing Guide', N'Covering indexes and filtered indexes…'),

&nbsp;      (3, N'Backup Strategy', N'Weekly full, daily diff, hourly log…');

UPDATE d SET Embedding = dbo.Emb384.INFER(Body)

FROM dbo.Docs AS d

WHERE d.Embedding IS NULL;

\-- 5) Query

DECLARE @q NVARCHAR(MAX) = N'How to choose filtered indexes for OLTP';

DECLARE @qv VECTOR(384)  = dbo.Emb384.INFER(@q);

SELECT TOP (5)

&nbsp;   DocId, Title,

&nbsp;   VECTOR_DISTANCE(Embedding, @qv) AS distance_

_FROM dbo.Docs_

_WHERE VECTOR_SEARCH(Embedding, @qv) = 1

ORDER BY distance ASC;

\`\`

This demonstrates **creating**, **indexing**, **embedding**, and **ANN querying** with VECTOR_SEARCH.\\ For deeper examples and RAG patterns, see the Microsoft Learn module and Intelligent Applications guidance. [\[hugobarona.com\]](https://www.hugobarona.com/optimizing-your-sql-database-workloads-with-automatic-tuning-on-azure/), [\[youtube.com\]](https://www.youtube.com/watch?v=oRXylMoL6EM)

**Further reading / references**

- Microsoft Learn: **Build AI‑powered solutions using SQL Server 2025** (vectors, embeddings, RAG, external models) [\[hugobarona.com\]](https://www.hugobarona.com/optimizing-your-sql-database-workloads-with-automatic-tuning-on-azure/)
- Microsoft Learn: **Intelligent applications and AI (SQL Server/Azure SQL)**-RAG concepts and vector examples [\[youtube.com\]](https://www.youtube.com/watch?v=oRXylMoL6EM)
- DBI Services: **Vector Indexes & Semantic Search Performance**-VECTOR_SEARCH vs VECTOR_DISTANCE, DiskANN and recall guidance [\[axial-sql.com\]](https://axial-sql.com/building-intelligent-applications-with-sql-server-and-azure-cognitive-services/)
- MSSQLTips: **Vector Search in SQL Server 2025**-dimensions, client support (SSMS 21), use cases [\[azurelessons.com\]](https://azurelessons.com/azure-cognitive-services-tutorial/)
- Anthony Nocentino: **Ollama + SQL Server 2025 FastStart**-CREATE EXTERNAL MODEL with TLS and embeddings pipeline

**DBA/Platform Engineer to _use_ AI in SQL Server with minimal coding**

**1) What you'll enable (and why)**

- **Query Store** to capture plans + runtime stats and enable advanced tuning features.\\ Applies to SQL Server 2016+ and is **on by default** in SQL Server 2022+ (still validate settings). [\[github.com\]](https://github.com/Azure-Samples/SQL-AI-samples)
- **Automatic Plan Correction** to auto‑force last good plans on regressions (on‑prem/VM and Azure SQL). [\[coursera.org\]](https://www.coursera.org/learn/databricks-machine-learning-fundamentals)
- **Query Store Hints** to shape individual plans **without changing application SQL** (SQL Server 2022+, Azure SQL). [\[github.com\]](https://github.com/Azure-Samples/SQL-AI-samples)
- **Machine Learning Services + sp_execute_external_script** to run small Python anomaly detectors inside SQL Server. [\[sqlyard.com\]](https://sqlyard.com/2025/09/10/sql-server-machine-learning-services-a-practical-guide-for-dbas-developers-and-data-warehouse-teams/), [\[youtube.com\]](https://www.youtube.com/watch?v=dDJheVYgeVo)
- **Intelligent Query Processing (IQP)** by setting compatibility level (e.g., 160 for SQL 2022; 170 for SQL 2025) for automatic gains (PSPO, CE feedback, etc.). [\[youtube.com\]](https://www.youtube.com/watch?v=JD0Zo6LvUKo)
- **SQL Server 2025 Vector features** (optional but powerful): VECTOR(n) type, **DiskANN** index, VECTOR_SEARCH, and CREATE EXTERNAL MODEL for embeddings-enabling semantic/RAG use cases in T‑SQL. [\[hugobarona.com\]](https://www.hugobarona.com/optimizing-your-sql-database-workloads-with-automatic-tuning-on-azure/), [\[axial-sql.com\]](https://axial-sql.com/building-intelligent-applications-with-sql-server-and-azure-cognitive-services/)

**2) Architecture (high level)**

**2.1 AI Tuning Assistant (Mermaid diagram)**

flowchart LR

&nbsp; A\[Workload telemetry\\nQuery Store + DMVs\] --> B\[Analyzer\\nPython via sp_execute_external_script\]

&nbsp; B --> C\[Recommender\\nLLM summary (Azure OpenAI) or SSMS Copilot\]

&nbsp; C --> D{Executor}

&nbsp; D -->|Safe| E\[Automatic Plan Correction\\n(force last good plan)\]

&nbsp; D -->|Targeted| F\[Query Store Hints\\n(MAXDOP, join hints)\]

&nbsp; D -->|Azure SQL| G\[Automatic Indexing\\n(create/drop)\]

&nbsp; E --> H\[Monitor & Validate\\nQuery Store deltas\]

&nbsp; F --> H

&nbsp; G --> H

- **Telemetry**: DMVs + Query Store give reliable performance insights. [\[montecarlodata.com\]](https://www.montecarlodata.com/blog-just-launched-ai-anomaly-detection-for-sql-server/)
- **Executor**: Safe, reversible actions-APC and Azure Automatic Tuning validate and **auto‑rollback** if no gain. [\[coursera.org\]](https://www.coursera.org/learn/databricks-machine-learning-fundamentals), [\[bhushangawale.com\]](https://bhushangawale.com/2025/08/build-intelligent-sql-agents-with-openai-azure-foundry-and-sql-mcp/)

**2.2 Vector Search (Mermaid diagram)**

![A screenshot of a computer screen

AI-generated content may be incorrect.](data:image/png;base64,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X/7yD7vaxqnvfe/Xre19//uHdbVVrfS+LtexW2qdeuo/WvsjZdv61V/+cmV7Pfl/2761F4Hs+AhkKWo2i0AWwEybRCA7NzfXqq985UddbWld//o7tvo94xkv6Gqb9lq/fmNr30844S/tZde+9rXb932U+s53ftW1/Vko+cJVq9W77s8OO1x783e/e2hXf2r4IpDFpCxHILvTTjfqel/oVXZdqn+97W3vbx237bffvqtt2Hrwgx+5+Xa3u0vX8rTkb5vczgUXXNPVtlL16le/tXWb17ve9bvaxqkQ9mltb599bt/VNk795jebNv/pT//qWGafz73qLne5R9f2lrO8X7yv173u9braJlE/+MFv2vfdtvWrM864qL3emWde3NF2/vlXb77xjXfZvM0223Q9DtNYn/nMtzafddYlXcuXUgSy45t0ICvP2T32uFXXe8O2227X9zOzvA7ucpf9u9bbbrvtNn/1qz/p6p+W9v32t3/Z1TZOnXbaPzbf8IY7Zfflpz89qqs/taXkb2ru2B1wwIGb//znS7v6d6573uab3OSmHevJe/2RR57S1Vfqm988pOt2pN7//k919dXSv5f96pBDjular4wikAUw0whkl7/OOefy1n5vu+22HV9WZyGQPf30Czc/5zkv6Vo+an396z/tuh+2bnSjGzPCZcwikMWkzFogK+/BRx55aivMs21VrOUIZHfaaaeB6z/72f/Vup1jjz27q22lapoDWRmxKaGDXW6fz72KQHa46hfIyqhwbXv+81/ete60lYQlsq9/+tPyhbIEsuObZCArz2X7npCW982udaR+9as/dvW1de1rX2fzuef+u2tdKe2zHIGsnMFgbzut/fe/T9c61GLJmS32eNk67bR/dq0n9etfH9/VNy0JX9P+97nPAV190rrJTXbN/tBKIAsAK4RAdvnrS19a/FJwwAEP61j+tKc9b/OTn/ysjjrooCe3j8ejHvXErnapI47I/8K53PWKV7yxtR877niDrrZR6rDDTmjfJ/llX754adumTRdsvsENtvwCfOMb3yT7h5/qXwSymJTlDGRvdrPdu97vbNl1R61rXWuH1m294AX/3dVWxVpqICvvx/r+fPTRZ3S1a93sZqtafd71ro90ta1UTWsge/zx5/Y8FnosH/KQR3U9t9N685vf3bXuctbWEMhKyfNefgw/5ZS/d7VN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iprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUoiprOIpAdH4EsRc1mEcgCmGkEshQ1e0Ugi0khkKUo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)

- **DiskANN** speeds up ANN queries with high recall. Use exact VECTOR_DISTANCE when collections are small. [\[axial-sql.com\]](https://axial-sql.com/building-intelligent-applications-with-sql-server-and-azure-cognitive-services/)

**3) Environment checklist**

- SQL Server **2017+** for Automatic Plan Correction; **2022+** for Query Store Hints; **2025** for vector features. [\[coursera.org\]](https://www.coursera.org/learn/databricks-machine-learning-fundamentals), [\[github.com\]](https://github.com/Azure-Samples/SQL-AI-samples), [\[hugobarona.com\]](https://www.hugobarona.com/optimizing-your-sql-database-workloads-with-automatic-tuning-on-azure/)
- **SSMS 21+** for full vector support (2025). [\[azurelessons.com\]](https://azurelessons.com/azure-cognitive-services-tutorial/)
- **Machine Learning Services (Python)** installed; enable external scripts. [\[sqlyard.com\]](https://sqlyard.com/2025/09/10/sql-server-machine-learning-services-a-practical-guide-for-dbas-developers-and-data-warehouse-teams/)
- Set DB compatibility level (**160** for 2022, **170** for 2025) to unlock IQP features. [\[youtube.com\]](https://www.youtube.com/watch?v=JD0Zo6LvUKo)

**4) Scripts (copy‑paste safe, with comments)**

**4.1 Enable Query Store + Automatic Plan Correction**

\-- Enable Query Store (required by APC & Query Store Hints)

ALTER DATABASE \[YourDB\] SET QUERY_STORE = ON;_

_ALTER DATABASE \[YourDB\] SET QUERY_STORE (OPERATION_MODE = READ_WRITE);

\-- Enable Automatic Plan Correction (safe & reversible)

ALTER DATABASE \[YourDB\]

SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = ON);

**Why:** Query Store captures plans/stats and allows APC to force last good plan when regressions occur. [\[coursera.org\]](https://www.coursera.org/learn/databricks-machine-learning-fundamentals)

**4.2 Query Store Hints (apply/remove)**

\-- Inspect #anomalies output (below) to choose a query_id_

_DECLARE @QueryId BIGINT = 12345;_

_\-- Apply a conservative hint without changing app code_

_EXEC sys.sp_query_store_set_hints_

&nbsp; _@query_id = @QueryId,

&nbsp; @hint     = N'OPTION (MAXDOP 4)';

\-- Remove hints if needed (rollback)

EXEC sys.sp_query_store_remove_hints

&nbsp; @query_id = @QueryId;

**Notes:** Query Store Hints are available in SQL Server 2022+ and Azure SQL; use judiciously and monitor impact. [\[github.com\]](https://github.com/Azure-Samples/SQL-AI-samples)

**4.3 DMVs/Query Store - find top offenders**

\-- Azure SQL: quick resource lens (last hour)

SELECT TOP (100)

_FROM sys.dmdbresourcestats_

_ORDER BY endtime DESC;_

_\-- Query Store: top duration/CPU reads in last 24h, with text_

_WITH recent AS (_

&nbsp; _SELECT rs.planid, qs.queryid,_

&nbsp;        _MAX(rs.lastexecutiontime) AS lastexectime,_

&nbsp;        _AVG(rs.avgduration)        AS avgdurationms,_

&nbsp;        _AVG(rs.avgcputime)        AS avgcpums,_

&nbsp;        _AVG(rs.avglogicalioreads)AS avgreads,_

&nbsp;        _COUNT()                    AS sample_count

&nbsp; FROM sys.query_store_runtime_stats AS rs_

&nbsp; _JOIN sys.query_store_plan  AS qp ON rs.plan_id = qp.plan_id_

&nbsp; _JOIN sys.query_store_query AS qs ON qp.query_id = qs.query_id_

&nbsp; _WHERE rs.last_execution_time > DATEADD(HOUR, -24, SYSUTCDATETIME())_

&nbsp; _GROUP BY rs.plan_id, qs.query_id_

_)_

_SELECT TOP (100)_

&nbsp; _r.\*, qt.query_sql_text AS query_text

FROM recent r

JOIN sys.query_store_query AS q

&nbsp; ON q.query_id = r.query_id

JOIN sys.query_store_query_text AS qt_

&nbsp; _ON qt.query_text_id = q.query_text_id_

_ORDER BY avg_duration_ms DESC;

**Why:** DMVs and Query Store provide the ground truth to prioritize tuning. [\[montecarlodata.com\]](https://www.montecarlodata.com/blog-just-launched-ai-anomaly-detection-for-sql-server/)

**4.4 Enable Python and run an anomaly detector in‑database**

\-- One-time: allow external scripts

EXEC sp_configure 'external scripts enabled', 1;_

_RECONFIGURE;_

_\-- Create temp table from the Query Store query above_

_IF OBJECT_ID('tempdb..#hot_queries') IS NOT NULL DROP TABLE #hot_queries;

SELECT TOP (200)

&nbsp; r.query_id, r.plan_id, r.last_exec_time,

&nbsp; r.avg_duration_ms, r.avg_cpu_ms, r.avg_reads, r.sample_count,

&nbsp; r.query_text_

_INTO #hot_queries

FROM (

&nbsp; /\* paste the Query Store query from section 4.3 here and wrap as a derived table _/_

&nbsp; _SELECT rs.planid, qs.queryid,_

&nbsp;        _MAX(rs.lastexecutiontime) AS lastexectime,_

&nbsp;        _AVG(rs.avgduration)        AS avgdurationms,_

&nbsp;        _AVG(rs.avgcputime)        AS avgcpums,_

&nbsp;        _AVG(rs.avglogicalioreads)AS avgreads,_

&nbsp;        _COUNT()                    AS sample_count,

&nbsp;        qt.query_sql_text AS query_text_

&nbsp; _FROM sys.query_store_runtime_stats AS rs

&nbsp; JOIN sys.query_store_plan  AS qp ON rs.plan_id = qp.plan_id

&nbsp; JOIN sys.query_store_query AS qs ON qp.query_id = qs.query_id

&nbsp; JOIN sys.query_store_query_text AS qt ON qt.query_text_id = qs.query_text_id_

&nbsp; _WHERE rs.last_execution_time > DATEADD(HOUR, -24, SYSUTCDATETIME())_

&nbsp; _GROUP BY rs.plan_id, qs.query_id, qt.query_sql_text_

_) r_

_ORDER BY r.avg_duration_ms DESC;_

_\-- Python IsolationForest flags anomalies_

_DECLARE @py NVARCHAR(MAX) = N'_

_import pandas as pd_

_from sklearn.ensemble import IsolationForest_

_df = InputDataSet.copy()_

_for col in \["avg_duration_ms","avg_cpu_ms","avg_reads"\]:

&nbsp;   df\[col\] = df\[col\].fillna(0)

model = IsolationForest(n_estimators=100, contamination=0.02, random_state=42)

df\["anomaly"\] = model.fit_predict(df\[\["avg_duration_ms","avg_cpu_ms","avg_reads"\]\])

OutputDataSet = df\[df\["anomaly"\]==-1\]\[

&nbsp;   \["query_id","plan_id","last_exec_time","avg_duration_ms","avg_cpu_ms","avg_reads","sample_count","query_text"\]_

_\]_

_';_

_IF OBJECT_ID('tempdb..#anomalies') IS NOT NULL DROP TABLE #anomalies;

CREATE TABLE #anomalies(

&nbsp; query_id BIGINT, plan_id BIGINT, last_exec_time DATETIME2(7),

&nbsp; avg_duration_ms FLOAT, avg_cpu_ms FLOAT, avg_reads FLOAT,_

&nbsp; _sample_count BIGINT, query_text NVARCHAR(MAX)_

_);_

_INSERT INTO #anomalies_

_EXEC sp_execute_external_script

&nbsp; @language = N'Python',

&nbsp; @script   = @py,

&nbsp; @input_data_1 = N'SELECT \* FROM #hot_queries',_

&nbsp; _@output_data_1_name = N'OutputDataSet';

\-- Apply a hint to the worst anomaly (optional)

DECLARE @QueryId BIGINT = (SELECT TOP (1) query_id FROM #anomalies ORDER BY avg_duration_ms DESC);_

_IF @QueryId IS NOT NULL_

_BEGIN_

&nbsp; _EXEC sys.sp_query_store_set_hints @query_id=@QueryId, @hint=N'OPTION (MAXDOP 4)';

&nbsp; PRINT CONCAT('Hint applied to query_id=', @QueryId, '. Review impact in Query Store.');

END;

**Why:** sp_execute_external_script is the supported method to run Python/R in SQL Server; perfect for lightweight ML without moving data. [\[sqlyard.com\]](https://sqlyard.com/2025/09/10/sql-server-machine-learning-services-a-practical-guide-for-dbas-developers-and-data-warehouse-teams/)

**4.5 IQP: set DB compatibility level (free improvements)**

\-- SQL Server 2022

ALTER DATABASE \[YourDB\] SET COMPATIBILITY_LEVEL = 160;_

_\-- SQL Server 2025_

_\-- ALTER DATABASE \[YourDB\] SET COMPATIBILITY_LEVEL = 170;

**What you get:** PSPO (multiple plans for parameter‑sensitive queries), CE feedback, optimized sp_executesql, etc., often improving performance **with no code changes**. [\[youtube.com\]](https://www.youtube.com/watch?v=JD0Zo6LvUKo)

**4.6 Vector Search (SQL Server 2025 only)**

\-- Table with vector embeddings

CREATE TABLE dbo.Docs (

&nbsp; DocId INT PRIMARY KEY,

&nbsp; Title NVARCHAR(200),

&nbsp; Body  NVARCHAR(MAX),

&nbsp; Embedding VECTOR(384)

);

\-- DiskANN index for ANN search

CREATE VECTOR INDEX IX_Docs_Embedding

&nbsp; ON dbo.Docs(Embedding)

&nbsp; USING DISKANN;

\-- Register external embedding model (Azure OpenAI/Ollama/etc.)

CREATE EXTERNAL MODEL dbo.Emb384

WITH (ENDPOINT = 'https://&lt;your-embedding-endpoint&gt;',

&nbsp;     AUTHENTICATION = 'ManagedIdentity'); -- or ApiKey

\-- Populate embeddings

UPDATE d SET Embedding = dbo.Emb384.INFER(d.Body)

FROM dbo.Docs AS d

WHERE d.Embedding IS NULL;

\-- Query: ANN + exact distance sort

DECLARE @q NVARCHAR(MAX) = N'Filtered indexes for OLTP workloads';

DECLARE @qv VECTOR(384)  = dbo.Emb384.INFER(@q);

SELECT TOP (10)

&nbsp; DocId, Title, VECTOR_DISTANCE(Embedding, @qv) AS distance_

_FROM dbo.Docs_

_WHERE VECTOR_SEARCH(Embedding, @qv) = 1

ORDER BY distance ASC;

**Guidance:** Use VECTOR_SEARCH for large collections and VECTOR_DISTANCE for smaller sets or validation; filter first for speed. [\[axial-sql.com\]](https://axial-sql.com/building-intelligent-applications-with-sql-server-and-azure-cognitive-services/)

**5) Operational guidance (safe & reversible)**

- **Canary changes**: apply hints/APC during off‑peak; monitor Query Store deltas before rolling broadly. [\[github.com\]](https://github.com/Azure-Samples/SQL-AI-samples)
- **Azure Automatic Tuning**: enable Force last good plan and Create/Drop index-Azure validates and **auto‑reverts** if needed. [\[youtube.com\]](https://www.youtube.com/watch?v=6joGkZMVX4o), [\[bhushangawale.com\]](https://bhushangawale.com/2025/08/build-intelligent-sql-agents-with-openai-azure-foundry-and-sql-mcp/)
- **Model governance** (vector): track model/version used for embeddings; mixing models affects similarity space. [\[hugobarona.com\]](https://www.hugobarona.com/optimizing-your-sql-database-workloads-with-automatic-tuning-on-azure/)
- **Security**: prefer **Managed Identity** when invoking Azure OpenAI; avoid hardcoded keys in T‑SQL. [\[hugobarona.com\]](https://www.hugobarona.com/optimizing-your-sql-database-workloads-with-automatic-tuning-on-azure/)

**6) Clickable resource index (free)**

- **Intelligent Query Processing** (features & compatibility levels)\\ <https://learn.microsoft.com/en-us/sql/relational-databases/performance/intelligent-query-processing?view=sql-server-ver17> [\[youtube.com\]](https://www.youtube.com/watch?v=JD0Zo6LvUKo)
- **Query Store Hints** (apply/remove; supported hints)\\ <https://learn.microsoft.com/en-us/sql/relational-databases/performance/query-store-hints?view=sql-server-ver17> [\[github.com\]](https://github.com/Azure-Samples/SQL-AI-samples)
- **Automatic Tuning (SQL Server)** and **Azure Automatic Tuning** (create/drop index, force plan, rollback safety)\\ <https://learn.microsoft.com/en-us/sql/relational-databases/automatic-tuning/automatic-tuning?view=sql-server-ver17\\> <https://learn.microsoft.com/en-us/azure/azure-sql/database/automatic-tuning-overview?view=azuresql\\> <https://learn.microsoft.com/en-us/azure/azure-sql/database/automatic-tuning-enable?view=azuresql> [\[coursera.org\]](https://www.coursera.org/learn/databricks-machine-learning-fundamentals), [\[bhushangawale.com\]](https://bhushangawale.com/2025/08/build-intelligent-sql-agents-with-openai-azure-foundry-and-sql-mcp/), [\[youtube.com\]](https://www.youtube.com/watch?v=6joGkZMVX4o)
- **Machine Learning Services and sp_execute_external_script** (Python/R inside SQL Server)\\ <https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-execute-external-script-transact-sql?view=sql-server-ver17> [\[sqlyard.com\]](https://sqlyard.com/2025/09/10/sql-server-machine-learning-services-a-practical-guide-for-dbas-developers-and-data-warehouse-teams/)
- **DMVs monitoring** (Azure SQL/SQL Server)\\ <https://learn.microsoft.com/en-us/azure/azure-sql/database/monitoring-with-dmvs?view=azuresql> [\[montecarlodata.com\]](https://www.montecarlodata.com/blog-just-launched-ai-anomaly-detection-for-sql-server/)
- **SQL Server 2025 AI: vectors, embeddings, RAG, external models**\\ Training module: <https://learn.microsoft.com/en-us/training/modules/build-ai-solutions-sql-server/\\> Overview: <https://learn.microsoft.com/en-us/sql/sql-server/ai/artificial-intelligence-intelligent-applications?view=sql-server-ver17\\> DiskANN/ANN guidance: <https://www.dbi-services.com/blog/sql-server-2025-vector-indexes-semantic-search-performance/\\> SSMS 21 & vector tips: <https://www.mssqltips.com/sqlservertip/8299/vector-search-in-sql-server/> [\[hugobarona.com\]](https://www.hugobarona.com/optimizing-your-sql-database-workloads-with-automatic-tuning-on-azure/), [\[youtube.com\]](https://www.youtube.com/watch?v=oRXylMoL6EM), [\[axial-sql.com\]](https://axial-sql.com/building-intelligent-applications-with-sql-server-and-azure-cognitive-services/), [\[azurelessons.com\]](https://azurelessons.com/azure-cognitive-services-tutorial/)