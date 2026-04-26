# Autopredator Databases

This folder provisions all logical databases for Autopredator on MariaDB/MySQL (InnoDB, `utf8mb4_unicode_ci`). Each table uses snake_case, BIGINT primary keys, and `created_at/updated_at` audit columns.

## Layout and rationale
- Separate logical databases: `autopredator_core`, `autopredator_cars_research`, `autopredator_pricing`, `autopredator_site_cms`, `autopredator_marketplace`, `autopredator_ingestion_staging`, `autopredator_analytics_events`.
- Cross-database foreign keys are not supported in MySQL/MariaDB. Canonical referential integrity is enforced within each database. Shared lookups (states/cities) are duplicated in `pricing` and `marketplace` to keep local FK safety; cross-DB joins are still possible for reporting/tests.
- Idempotency: `CREATE IF NOT EXISTS` and `ON DUPLICATE KEY UPDATE` in seeds allow safe re-runs.

## Running locally
1) Create databases:
```sh
mysql -u root -p < db/00_create_databases.sql
```

2) Apply migrations in order:
```sh
for f in db/migrations/V*.sql; do mysql -u root -p < "$f"; done
```
On Windows PowerShell:
```powershell
Get-ChildItem db/migrations/V*.sql | ForEach-Object { Get-Content $_ | mysql -u root -p }
```

3) Load seeds (order not critical because IDs are explicit):
```sh
for f in db/seeds/*.sql; do mysql -u root -p < "$f"; done
```

4) Run tests/validation queries (expect empty resultsets for orphan/duplicate checks):
```sh
mysql -u root -p < db/tests/test_queries.sql
```

### Hardening autopredator_cars
- Apply the hardening migration (idempotent; safe to re-run):
```sh
mysql -u root -p < db/migrations/2026-01-08_autopredator_cars_hardening.sql
```
- Verify the enforced constraints (all results should be `0` bad rows):
```sh
mysql -u root -p < db/checks/verify_constraints.sql
```

## Notable constraints and indexes
- Examples: `variants(model_id, fuel_type_id, transmission_id)`, `variant_specs(spec_definition_id, variant_id)`, `variant_features(feature_id, variant_id)`, `price_history(variant_id, city_id, price_type, captured_on)`, `pages(slug)` + `(page_type,status)`, `events(event_type, occurred_at)` and `(page_id, occurred_at)`.
- Unique constraints on slugs, feature/spec codes, manufacturer names, tags, etc.
- On-road components split into componentized amounts for flexible tax changes.

## Seeds coverage
- Research: 5 segments/body_types/fuel_types/transmissions, 2 manufacturers, 2 families, 3 models, 6 variants, 5 spec categories, 24 spec definitions, 30 features, representative variant specs/features/media.
- Pricing: 2 states / 10 cities, 30 price_history rows across variants and cities, on-road component breakdowns.
- Marketplace: duplicated states/cities plus sample listings/leads.
- CMS: home + model pages, FAQs, starter blog post, tags, redirect.
- Core: baseline roles/permissions.

## Extending
- Add new migrations as `db/migrations/V0008__description.sql` with `USE <database>;`.
- Keep cross-database relationships in application logic or views; avoid implicit FK assumptions across databases.
