# Data Retention

- **PostgreSQL**
  - Core entities (users, organizations, catalog, fleet) kept indefinitely.
  - Leads/offers: retain full history; archive to cold storage after 24 months if tables grow too large.
  - Audit-style tables (`lead_status_history`, `finance_status_history`): keep 24 months active, then archive.
  - `price_history`: partitioned monthly; keep 36 months online, drop/arch archive older partitions.
- **Redis**
  - Cache/coordination only; max TTL 24h (OTP 10m, lead throttle 5m, listings cache 10m/30m).
  - No persistence expectations beyond AOF replay for local dev.
- **OpenSearch**
  - Keep active indexes for 180 days; apply ILM in prod to roll over by size/time.
  - Rebuild indexes from Postgres using `scripts/reindex_opensearch.py` when mappings change.
- **ClickHouse**
  - Event tables retain 13 months online; older partitions can be dropped or moved to S3 if configured.
  - Avoid PII in `metadata`; use session/user IDs only when necessary for funnel analytics.
