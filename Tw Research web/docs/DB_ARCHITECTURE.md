# Autopredator Data Layer

This document explains the data plane for the Autopredator-style app: what each datastore owns, how data flows across them, and how to operate the stack locally and in higher environments.

## Components and Data Ownership
- **PostgreSQL (OLTP, source of truth):** schemas `auth`, `catalog`, `pricing`, `market`, `crm`, `ops`. All authoritative writes land here. Migrations live in `infra/db/migrations` (Flyway).
- **Redis (cache/queue):** transient cache for hot listing pages, session tokens, and lightweight queues. No source-of-truth data; safe to flush.
- **OpenSearch (search/read index):** denormalized documents for fast listing search (`listings_search`) and catalog suggestions (`catalog_suggest`). Derived from Postgres.
- **ClickHouse (analytics):** append-only events (`events`, partitioned by month) and session metadata (`sessions`). Derived, recomputable from raw events.
- **MinIO/S3 (media & backups):** object storage for listing media, exports, and backups/snapshots of other datastores.

Ownership rule: Postgres is authoritative; OpenSearch/Redis/ClickHouse are derived and can be rebuilt. Media uploaded to MinIO is canonical for binary assets.

## Data Flows
- **Writes:** API writes to Postgres. Background worker (or outbox) fans out changes:
  1. Persist transactional record in Postgres.
  2. Publish change event (e.g., `LISTING_UPDATED`) to a queue or outbox table.
  3. Consumer updates OpenSearch index and invalidates Redis cache keys.
- **Reads:** API first checks Redis for cached listing detail; on miss, read Postgres (or OpenSearch for search-heavy endpoints), then hydrate cache.
- **Search build:** `scripts/search_reindex.py` pulls Postgres rows, denormalizes, and bulk indexes to OpenSearch using templates in `infra/search/templates`.
- **Analytics ingest:** `scripts/analytics_ingest.py` exposes `POST /events` to insert rows into ClickHouse `autopredator_analytics.events`.

## Postgres Schema Highlights
- **auth:** users, organizations, org_members with uniqueness on emails and org-user pairs.
- **catalog:** manufacturers → model_families → models → variants, with lookups (`fuel_types`, `transmission_types`, `body_types`), specs, features, and variant_feature mapping.
- **pricing:** cities + price_quotes with unique (variant_id, city_id, quote_date) and index `idx_price_quotes_variant_city_date_desc` for time-sorted quotes.
- **market:** listings (denormalized fuel/transmission for fast filtering), listing_media, inspections. Index `idx_listings_filters` supports city/price/year/km/fuel/transmission/status filters.
- **crm:** leads + lead_activities with `idx_leads_org_status_created` to power pipelines by org/status/created_at.
- **ops:** audit_logs (indexed by entity_type/entity_id) and import_jobs.
- **Partition note:** `pricing.price_quotes` is not partitioned. To add monthly partitioning later, convert the table to list partitions on `to_char(quote_date, 'YYYYMM')` and update Flyway with a V3 migration.

## Search Indexing
- **Templates:** `infra/search/templates/listings_search.json` (listing filter fields, keyword-normalized city/fuel/transmission, text title/description) and `infra/search/templates/catalog_suggest.json` (completion suggester).
- **Indexes:** default names `listings_search`, `catalog_suggest` (override via env).
- **Full rebuild:** `make search-reindex` → runs `scripts/search_reindex.py` to read Postgres and bulk index.
- **Incremental sync strategy:** use Postgres outbox table or logical replication slot to capture listing/catalog changes; a worker reads events and upserts docs in OpenSearch and deletes/refreshes Redis cache keys. Keep OpenSearch stateless by allowing nightly `search-reindex` backfills.

## Analytics (ClickHouse)
- **Tables:** created via `infra/clickhouse/init.sql`:
  - `autopredator_analytics.events` (MergeTree, partitioned monthly, ordered by event_time/name/session_id).
  - `autopredator_analytics.sessions` (ReplacingMergeTree).
- **Ingestion:** run `python scripts/analytics_ingest.py` (port `ANALYTICS_INGEST_PORT`, default 8088); POST JSON events with `name`, `session_id`, `properties`.
- **Example queries:**
  - Funnel (search → view → lead):
    ```sql
    SELECT name, count() AS events
    FROM autopredator_analytics.events
    WHERE event_date >= today() - 7
      AND name IN ('search', 'listing_view', 'lead_submit')
    GROUP BY name
    ORDER BY events DESC;
    ```
  - Top searches (term frequency):
    ```sql
    SELECT properties['q'] AS query, count() AS hits
    FROM autopredator_analytics.events
    WHERE name = 'search' AND event_date >= today() - 14
    GROUP BY query
    ORDER BY hits DESC
    LIMIT 20;
    ```

## Backup and Restore
- **Postgres:** `pg_dump -Fc` nightly; store dumps in MinIO/S3. For point-in-time, enable WAL archiving to the bucket. Restore with `pg_restore -d <db> backup.dump`.
- **Redis:** append-only file enabled; treat as cache (periodic RDB optional). No backup required beyond AOF.
- **OpenSearch:** local single-node uses security disabled; take snapshot repositories pointing to MinIO/S3 for restorable backups. Can be rebuilt from Postgres + reindex.
- **ClickHouse:** use `BACKUP TABLE ... TO S3('s3://bucket/path', 'ACCESS_KEY','SECRET_KEY')` on a schedule. Restore with `RESTORE ...`.
- **MinIO:** rely on object storage durability; mirror bucket to cloud S3 in staging/prod if needed.

## Environments
- **Local:** Docker Compose (`infra/docker-compose.yml`) with security relaxed for OpenSearch, MinIO credentials from `infra/.env`. Services share `autopredator_data_net`.
- **Staging:** enable TLS for OpenSearch and MinIO; stronger passwords; restrict exposed ports to internal networks or VPN; keep same schema and migrations.
- **Production:** managed Postgres/Redis/OpenSearch/ClickHouse/S3 or hardened self-hosted; rotate credentials; enable backups/WAL/archive, snapshots, encryption at rest, and network ACLs. Run migrations via CI/CD using Flyway.

## Operations Cheatsheet
- Copy `infra/.env.example` to `infra/.env` and fill secure values.
- Bring services up/down: `make infra-up` / `make infra-down`.
- Run schema + seed migrations: `make db-migrate` (includes seeds).
- Rebuild search indexes: `make search-reindex`.
- Smoke test connectivity: `make smoke-test`.
- Analytics ingest stub: `python scripts/analytics_ingest.py` (requires ClickHouse up).
