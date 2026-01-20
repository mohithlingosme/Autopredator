# Database layer (PostgreSQL 16+)

Multi-tenant, single-schema PostgreSQL with strict Row Level Security (RLS). All tenant tables carry `org_id UUID` and amounts are stored in paise (`BIGINT`). Timestamps are UTC (`timestamptz`); organizations have a timezone setting for presentation.

## Run Postgres locally
- Install Docker and Docker Compose.
- From repo root: `docker compose -f db/docker-compose.yml up -d`
- Connection defaults: `postgres://postgres:postgres@localhost:5432/fleetmanager`

## Apply schema and seed
1. `psql "$DATABASE_URL" -f db/schema.sql`
2. `psql "$DATABASE_URL" -f db/rls.sql`
3. `psql "$DATABASE_URL" -f db/indexes.sql`
4. `psql "$DATABASE_URL" -f db/seed.sql`
5. `psql "$DATABASE_URL" -f db/tests/rls_smoke_test.sql`

`db/schema.sql` is idempotent and loads enums, tables, constraints, and `set_updated_at` triggers. Partitioning targets for later: `trip_events` and `audit_log` (time), `gps` if added.

## Tenant/RLS model
- `app.org_id` GUC must be set per request/transaction; policies enforce `org_id = current_setting('app.org_id')::uuid`.
- Helper: `SELECT set_tenant('<org_uuid>', '<user_uuid>'::uuid);` and `SELECT clear_tenant();`.
- Without `app.org_id`, reads/writes are denied. RLS is `FORCE`d on all tenant tables including `orgs`.
- `service_role` (created in `rls.sql`) can bypass tenant filtering for internal jobs; grant it only to trusted background roles.

## Data conventions
- UUID PKs (`gen_random_uuid()` via `pgcrypto`).
- Monetary: paise in `BIGINT`; GST fields present where relevant (`gst_amount_paise`, `tax_paise`).
- Soft delete only where needed (`documents.deleted_at`); everything else uses hard constraints.
- Files are not stored in DB—only URLs + metadata.

## Migrations and seeding
- This repo ships plain SQL. Use any migration runner that can execute the files in order above.
- `db/seed.sql` seeds two orgs (OrgA/OrgB) with users, roles, 3+ vehicles/drivers, trips, fuel/expense logs, maintenance ticket, invoice/payment, and documents. It sets `app.org_id` per insert to respect RLS.
- Smoke test `db/tests/rls_smoke_test.sql` asserts cross-tenant visibility and write attempts fail.

## Useful connections
- Shell into the container: `docker compose -f db/docker-compose.yml exec db psql -U postgres -d fleetmanager`
- Drop and recreate locally: `docker compose -f db/docker-compose.yml down -v` (clears data).
