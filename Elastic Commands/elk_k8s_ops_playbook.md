
# Elasticsearch + Kubernetes Operational Playbook

> Maintainer: Ramesh Muthuvazhakkappan  
> Last updated: 2026-01-06

---

## Table of Contents
- [Kubernetes Essentials](#kubernetes-essentials)
- [AWS EKS Kubeconfig](#aws-eks-kubeconfig)
- [Secrets & Authentication](#secrets--authentication)
- [Port Forwarding](#port-forwarding)
- [Elasticsearch Cluster & Nodes](#elasticsearch-cluster--nodes)
- [Index Management](#index-management)
- [Reindexing (3-step process)](#reindexing-3-step-process)
- [Templates & Aliases](#templates--aliases)
- [Snapshot & Restore](#snapshot--restore)
- [Cluster Routing & Recovery](#cluster-routing--recovery)
- [ILM (Index Lifecycle Management)](#ilm-index-lifecycle-management)
- [Performance: Slow Query Logs](#performance-slow-query-logs)
- [Logstash Pipelines & Kibana](#logstash-pipelines--kibana)
- [Cross-Cluster Search & Replication](#cross-cluster-search--replication)
- [Task Management](#task-management)
- [Helpful Cat APIs](#helpful-cat-apis)

> **Security note**: This document intentionally redacts passwords, access keys, and endpoints. Replace `<REDACTED>` with secure values from your secret store (e.g., Kubernetes Secrets, AWS Secrets Manager).

---

## Kubernetes Essentials
```bash
# Namespaces
kubectl get ns

# Create resources from YAML
kubectl create -f <path-to-yaml>

# Describe pod/namespace/service
kubectl describe pod/<name>
kubectl describe ns/<name>
kubectl describe service/<name>

# Export object YAML
kubectl get pod/<name> -o yaml > pod.yaml
kubectl get service/<name> -o yaml > svc.yaml
kubectl get ns/<name> -o yaml > ns.yaml

# Pods in a namespace
kubectl get pods -n elk-cluster

# Logs (follow)
kubectl logs -f -n elk-cluster poc-elasticsearch-es-master-data-ingest-0
kubectl logs -f -n elk-cluster poc-elasticsearch-es-master-data-ingest-1
kubectl logs -f -n elk-cluster poc-elasticsearch-es-master-data-ingest-2

# Exec into a pod or service-backed endpoint
kubectl exec -it poc-kibana-kb-xxxxxxxxx-xxxxx -n elk-cluster -- /bin/bash
kubectl exec -it service/qa-kibana-kb-http -n elk-cluster -- /bin/bash
```

## AWS EKS Kubeconfig
```bash
aws eks update-kubeconfig --name cloudtrust-lamm-eks-qa-usw2   --region us-west-2 --profile qa
aws eks update-kubeconfig --name cloudtrust-lamm-eks-prod-usw2 --region us-west-2 --profile prd
aws eks update-kubeconfig --name cloudtrust-shrd-eks-dev-usw2  --region us-west-2
```

## Secrets & Authentication
```bash
# Get Elastic user password from Secret (base64 decode)
kubectl get secret poc-elasticsearch-es-elastic-user -n elk-cluster -o=jsonpath='{.data.elastic}' | base64 --decode

# PowerShell base64 decode
powershell "[Text.Encoding]::UTF8.GetString([convert]::FromBase64String('<BASE64>'))"
```

## Port Forwarding
```bash
# Elasticsearch HTTP
kubectl port-forward service/poc-elasticsearch-es-http 9200 -n elk-cluster
kubectl port-forward service/qa-elasticsearch-es-http  9200 -n elk-cluster
kubectl port-forward service/elasticsearch-k8s-es-http 9200 -n elk-cluster-k8s
kubectl port-forward service/elasticsearch-siem-es-http 9200 -n elk-cluster-siem

# Kibana
kubectl port-forward pod/poc-kibana-v2-kb-xxxxxxxxx-xxxxx 5601 -n elk-cluster
kubectl port-forward service/poc-css-kibana-kb-http       5601 -n elk-cluster
kubectl port-forward pod/qa-kibana-external-kb-xxxxxxxxx 5601 -n elk-cluster
kubectl port-forward pod/kibana-k8s-kb-xxxxxxxxx          5601 -n elk-cluster-k8s
kubectl port-forward pod/kibana-siem-kb-xxxxxxxxx         5601 -n elk-cluster-siem
```

## Elasticsearch Cluster & Nodes
```bash
# Health & Nodes
curl -u elastic:<REDACTED> http://localhost:9200/_cat/health
curl -u elastic:<REDACTED> http://localhost:9200/_cat/nodes?v

# Node attributes / master
GET /_cat/nodeattrs?v
GET /_cat/master?v

# Allocation explain
GET _cluster/allocation/explain?pretty
```

## Index Management
```bash
# List indices
GET /_cat/indices?v&s=index
GET /_cat/indices?v&h=index,pri,rep,docs.count,store.size,creation.date.string

# Index settings
GET <index>/_settings

# Create index example
PUT test
GET test/_settings

# Delete index
DELETE <index>
```

## Reindexing (3-step process)
**Formula:** `shards = p * (1 + r)` where `p`=primary shards, `r`=replica count. (Use to estimate total shard copies.)

**Step 1 – Copy mapping from source index**
```http
GET /0810d458-687a-4e40-bd19-87272400d594-device-latest/_mapping
```

**Step 2 – Create destination index with desired settings & mappings**
```http
PUT /0810d458-687a-4e40-bd19-87272400d594-device-temp
{
  "settings": {
    "index": {
      "mapping": {"total_fields": {"limit": "25000"}},
      "number_of_shards": "15",
      "number_of_replicas": "2",
      "analysis": {
        "analyzer": {
          "lowercaseKeywordAnalyzer": {
            "filter": "lowercase",
            "tokenizer": "keyword"
          }
        }
      }
    }
  },
  "mappings": {
    "child": {
      "_routing": {"required": true}
      // ... include exact mappings collected in Step-1 ...
    }
  }
}
```

**Step 3 – Reindex data**
```http
POST /_reindex
{
  "source": {"index": "0810d458-687a-4e40-bd19-87272400d594-device-latest"},
  "dest":   {"index": "0810d458-687a-4e40-bd19-87272400d594-device-temp"}
}
```

## Templates & Aliases
```http
# Define index template
PUT /_template/delta_template_1
{
  "template": "*device-delta-*",
  "settings": {"number_of_shards": 2, "number_of_replicas": 1}
}

# List templates
GET /_template/
GET /_template/delta*

# Delete template
DELETE /_template/delta_template

# Aliases
POST /_aliases
{
  "actions" : [
    { "add" : { "index" : "qa-elk-vpc-reindex-2020.06.17", "alias" : "qa-elk-vpc-2020.06.17" } }
  ]
}
```

## Snapshot & Restore
```http
# Create FS repository
PUT /_snapshot/my_local_repo
{
  "type": "fs",
  "settings": {"location": "my_repo"}
}

# List snapshots in repo
GET /_cat/snapshots/my_local_repo
GET /_snapshot/my_local_repo/_all

# Create snapshot
PUT /_snapshot/my_local_repo/bank_20180710
{
  "indices": "bank",
  "ignore_unavailable": true,
  "include_global_state": false
}

# Restore snapshot
POST /_snapshot/my_local_repo/bank_20180710/_restore
{
  "indices": "tweets",
  "include_global_state": false
}

# S3 repository example
PUT /_snapshot/k8s-elk-qa-repo
{
  "type": "s3",
  "settings": {"bucket": "lamm-qa-k8s-elk-log-backup"}
}
```

### Snapshot Lifecycle Management (SLM)
```http
PUT /_slm/policy/poc-elk-hot-snapshot-policy
{
  "name": "<poc-elk-hot-indices-snapshot-{now}>",
  "schedule": "0 30 5 * * ?",
  "repository": "k8s-elk-repo",
  "config": {
    "indices": ["<poc-elk*-{now/d-1d}>", "<apm*>", "<auditbeat-*>"],
    "include_global_state": true
  }
}
```

## Cluster Routing & Recovery
```http
# Disable/limit allocation
PUT /_cluster/settings
{ "transient": { "cluster.routing.allocation.enable": "none" } }

PUT /_cluster/settings
{ "transient": { "cluster.routing.allocation.enable": "primaries" } }

# Move/allocate shards
POST /_cluster/reroute?retry_failed=true

# Allocate a shard explicitly
POST /_cluster/reroute
{
  "commands": [
    { "allocate": { "index": "my-index", "shard": 4, "node": "search03", "allow_primary": true } }
  ]
}

# Recovery tuning
PUT /_cluster/settings
{ "transient": { "indices.recovery.max_bytes_per_sec": "500mb" } }
```

## ILM (Index Lifecycle Management)
```http
# Attach ILM policy and rollover alias
PUT /k8s_controlplane-2020.08.13/_settings
{
  "index": {
    "lifecycle": {"name": "ilm-elk-ilm-policy"}
  }
}

# Explain ILM status
GET */_ilm/explain
```

## Performance: Slow Query Logs
```http
PUT /index/_settings
{
  "index.search.slowlog.threshold.query.warn":  "1s",
  "index.search.slowlog.threshold.query.info":  "500ms",
  "index.search.slowlog.threshold.query.debug": "1500ms",
  "index.search.slowlog.threshold.query.trace": "300ms",
  "index.search.slowlog.threshold.fetch.warn":  "500ms",
  "index.search.slowlog.threshold.fetch.info":  "400ms",
  "index.search.slowlog.threshold.fetch.debug": "300ms",
  "index.search.slowlog.threshold.fetch.trace": "200ms"
}
```

## Logstash Pipelines & Kibana
```conf
# Example Logstash pipeline (redacted credentials)
input {
  beats { port => 5044 host => "0.0.0.0" }
}
output {
  amazon_es {
    hosts => ["https://<ES-ENDPOINT>"]
    region => "<REGION>"
    aws_access_key_id => "<REDACTED>"
    aws_secret_access_key => "<REDACTED>"
  }
}
```

```bash
# Validate config
./bin/logstash -f config/my-pipeline.yml --config.test_and_exit
```

## Cross-Cluster Search & Replication
- **CCS**: Configure remote clusters with seed nodes; use `ccs_minimize_roundtrips=true` for latency-optimized searches.
- **CCR**: Active-passive replication at shard level; requires Platinum/Enterprise license.

## Task Management
```http
# List running reindex tasks
GET /_tasks?detailed=true&actions=*reindex&group_by=parents

# Cancel a task
POST /_tasks/<task_id>/_cancel
```

## Helpful Cat APIs
```http
GET /_cat/health?v
GET /_cat/nodes?v&h=id,name,ip,port,v,m
GET /_cat/nodeattrs?v
GET /_cat/master?v
GET /_cat/indices?v&s=docs.count:desc
GET /_cat/indices/*vpc*/?v&h=index,pri,rep,docs.count,pri.store.size,store.size,creation.date.string&s=creation.date.string
GET /_cat/shards?h=index,shard,prirep,state,unassigned.reason&s=state&v
```

---

## Notes & Best Practices
- Size shards to ~10–50GB for balanced performance; avoid oversharding.
- Set replicas based on node count and durability needs (e.g., `replicas=N-quorum`).
- Always snapshot before major changes (reindex, mapping updates).
- Use ILM to automate rollover and retention.
- Keep credentials in Secrets; never hardcode.

