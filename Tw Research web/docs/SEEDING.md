# Seeding the Autopredator data layer

This guide explains how to populate the local Postgres database with deterministic, realistic demo data for development and testing.

## Prerequisites
- Docker services up and migrated: `make infra-up && make db-migrate`
- Python deps installed: `pip install -r scripts/requirements.txt`
- `DATABASE_URL` set (or let `Makefile` derive from `infra/.env`)

## Commands
- Small preset (default): `make db-seed` (runs `--reset --small`)
- Medium preset: `make db-seed-medium` (runs `--reset --medium`)
- Large preset: `make db-seed-large` (runs `--reset --large`)
- Reset + medium seed explicitly: `make db-reset-and-seed`
- Preview only: `DATABASE_URL=... python scripts/seed/seed_db.py --dry-run --medium`
- Deterministic override: append `--seed <int>` to any run.

## Preset sizes (approximate rows)
- Small: listings ~1.2k, leads ~6k, users ~120, dealers 15, variants ~500, price_quotes ~180k (variants × cities × months).
- Medium (default): listings ~3k, leads ~20k, users ~200, dealers 25, variants ~500, price_quotes ~180k.
- Large: listings ~6k, leads ~60k, users ~400, dealers 40, variants ~600, price_quotes ~200k+.

## Data characteristics
- Lookups: fuel/transmission/body types, 15 Indian cities, 150+ features across Safety, Comfort, Infotainment, Exterior, Tech.
- Catalog: 12 manufacturers, 4-7 model families each, 1-3 models per family, 3-7 variants per model, with specs and variant_features.
- Pricing: 24 months of monthly quotes per (variant, city) with mild drift and occasional jumps.
- Auth/Orgs: 1 admin org + dealer orgs; org_members seeded with owner/manager/sales roles.
- Listings: 70% used / 30% new, realistic year/km/price, media 2-8 per listing, inspections for ~50% used.
- CRM: leads with activities (1-6 per lead) and status distribution; audit logs for listing + lead changes; import job records.

## Common failures and fixes
- DATABASE_URL missing: export `DATABASE_URL=postgresql://user:pass@localhost:5432/autopredator_dev` or use `make` targets.
- Connection refused: ensure `make infra-up` is running and Postgres port matches `infra/.env`.
- Permission denied on tables: run `make db-migrate` to ensure schema exists and credentials match.
- Long runtime: use `--small` preset or reduce counts in `scripts/seed/seed_config.json`.
- FK errors: re-run with `--reset` to truncate in dependency order.
