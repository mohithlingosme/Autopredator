# Database Requirements & Assumptions

- Stack: PostgreSQL 16 (primary), Redis 7 (cache/queues), OpenSearch 2.x (search), ClickHouse 24.x (analytics).
- API: FastAPI + SQLAlchemy + Alembic. Migrations live in `apps/api/app/db/migrations/`.
- Identifiers: UUID primary keys for most OLTP tables; timestamps are `timestamptz` with `created_at`/`updated_at`.
- Validation: year/odometer/price constrained with `CHECK`; status columns preferred over soft deletes.
- Partitioning: `price_history` partitioned by month (`effective_date`) with default partition; ClickHouse partitions by `toYYYYMM(event_time)`.
- Naming: snake_case tables/columns; lookup tables seeded separately (`003_seed_lookups`).
- Local runtime: everything bootstraps via `infra/docker/docker-compose.db.yml`; default creds live in `.env.example`.
- Search: denormalized docs for listings + catalog; rebuild via `scripts/reindex_opensearch.py`.
- Analytics: event tables only; no PII in ClickHouse payloads, keep `metadata` limited to anonymous attributes.
- Assumptions: India-only cities/states for now; Redis used strictly as cache/coordination (no persistence beyond 24h TTLs); security plugins disabled for local OpenSearch.
