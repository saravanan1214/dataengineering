# Beginner-friendly AI project ideas for DBA

**1\. Query Performance Anomaly Detector**

- **Goal:** Detect slow or abnormal queries using Query Store data.
- **How:**
  - Export Query Store stats (avg duration, CPU, reads).
  - Use Python IsolationForest or Z-score to flag anomalies.
- **Skills Learned:** Python basics, scikit-learn, SQL DMVs.
- **Tools:** SQL Server Machine Learning Services (sp_execute_external_script) or Jupyter Notebook.

**2\. Automatic Index Recommendation Dashboard**

- **Goal:** Suggest indexes for expensive queries.
- **How:**
  - Pull missing index DMVs (sys.dm_db_missing_index_details).
  - Use a simple rule-based or ML model to rank recommendations.
- **Skills Learned:** T-SQL DMVs, Python Pandas for ranking.
- **Tools:** Power BI or Python visualization.

**3\. Forecast Database Growth**

- **Goal:** Predict storage or workload trends.
- **How:**
  - Collect historical size and resource stats.
  - Apply simple forecasting (rolling averages or Prophet).
- **Skills Learned:** Time-series basics, Pandas.
- **Tools:** Jupyter Notebook or in-database Python.

**4\. Natural Language Query Assistant**

- **Goal:** Let users ask questions like "Show top 10 slow queries" in plain English.
- **How:**
  - Use Azure OpenAI GPT model.
  - Map natural language to T-SQL templates.
- **Skills Learned:** API calls, prompt engineering.
- **Tools:** Python + Azure OpenAI.

**5\. Log Summarizer for DBA Alerts**

- **Goal:** Summarize error logs or deadlock reports.
- **How:**
  - Feed logs to Azure Cognitive Services or OpenAI.
  - Generate concise summaries and recommendations.
- **Skills Learned:** Text analytics, API integration.
- **Tools:** Python + Azure Cognitive Services.

**6\. Semantic Search for DBA Knowledge Base**

- **Goal:** Search documentation by meaning, not keywords.
- **How:**
  - Store embeddings in SQL Server 2025 VECTOR column.
  - Use VECTOR_SEARCH for semantic queries.
- **Skills Learned:** Embeddings, vector search.
- **Tools:** SQL Server 2025 + Azure OpenAI.

# Structured roadmap for AI projects

**Phase 1: Query Performance Anomaly Detector (2-3 weeks)**

**Goal:** Detect slow or abnormal queries using Query Store data.  
**Steps:**

- Enable Query Store in SQL Server.
- Export Query Store stats (avg duration, CPU, reads).
- Use Python IsolationForest or Z-score to flag anomalies. **Resources:**
- <https://learn.microsoft.com/en-us/sql/relational-databases/performance/query-store>
- <https://www.kaggle.com/learn/python>
- <https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.IsolationForest.html>

**Phase 2: Automatic Index Recommendation Dashboard (2-3 weeks)**

**Goal:** Suggest indexes for expensive queries.  
**Steps:**

- Query DMVs: sys.dm_db_missing_index_details.
- Rank recommendations using Python Pandas.
- Visualize in Power BI or Jupyter Notebook. **Resources:**
- <https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-missing-index-details-transact-sql>
- <https://learn.microsoft.com/en-us/power-bi/>

**Phase 3: Forecast Database Growth (2 weeks)**

**Goal:** Predict storage or workload trends.  
**Steps:**

- Collect historical size and resource stats.
- Apply rolling averages or Prophet for forecasting. **Resources:**
- [DMVs for Monitoring](https://learn.microsoft.com/en-us/azure/azure-sql/database/monitoring-with-dmvs?view=azuresql)
- <https://facebook.github.io/prophet/docs/quick_start.html>

**Phase 4: Natural Language Query Assistant (3-4 weeks)**

**Goal:** Let users ask questions like "Show top 10 slow queries" in plain English.  
**Steps:**

- Use Azure OpenAI GPT model.
- Map natural language to T-SQL templates. **Resources:**
- <https://learn.microsoft.com/en-us/azure/ai-services/openai/>
- <https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/prompt-engineering>

**Phase 5: Log Summarizer for DBA Alerts (2 weeks)**

**Goal:** Summarize error logs or deadlock reports.  
**Steps:**

- Feed logs to Azure Cognitive Services or OpenAI.
- Generate concise summaries and recommendations. **Resources:**
- <https://learn.microsoft.com/en-us/azure/ai-services/text-analytics/>

**Phase 6: Semantic Search for DBA Knowledge Base (3-4 weeks)**

**Goal:** Search documentation by meaning, not keywords.  
**Steps:**

- Store embeddings in SQL Server 2025 VECTOR column.
- Use VECTOR_SEARCH for semantic queries. **Resources:**
- [SQL Server 2025 AI Features](https://learn.microsoft.com/en-us/sql/sql-server/ai/artificial-intelligence-intelligent-applications?view=sql-server-ver17)
- [Vector Search Guide](https://learn.microsoft.com/en-us/training/modules/build-ai-solutions-sql-server/)

**Estimated Timeline**

- Total: ~14-18 weeks (spread across 6 projects).
- You can run **Phase 1 and Phase 3 in parallel** for faster progress.