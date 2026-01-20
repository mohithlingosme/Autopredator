# Database Seed Data

Deterministic seed data for AutoPredator with India-only commercial vehicle coverage across IAM, catalog, marketplace, fleet, finance, and content.

## Files & Entry Points
- `apps/api/seed/seed.py` – orchestrates seeding with deterministic RNG and validations.
- `apps/api/seed/fixtures/lookups.py` – static lookup fixtures (states, cities, body types, axle configs, corridors).
- `apps/api/seed/generators/` – domain generators (lookups, IAM, catalog, marketplace, fleet, finance, content, report).
- `scripts/db_seed.sh` – shell wrapper (exports `.env` if present).
- `Makefile` targets:
  - `make db-seed MODE=small|medium|large`
  - `make db-reset MODE=…` (drop schema, migrate, seed)

## Modes & Volumes
Base counts match the minimum required data. Modes scale up while staying idempotent.

| Entity                    | small (base) | medium (~1.5x) | large (~3x) |
|---------------------------|--------------|----------------|-------------|
| Manufacturers             | 15           | 23             | 45          |
| Model families            | 60           | 90             | 180         |
| Models                    | 120          | 180            | 360         |
| Variants                  | 300          | 450            | 900         |
| Price history rows        | 54,000       | 81,000         | 162,000     |
| Listings (used/new)       | 5,000 / 500  | 7,500 / 750    | 15,000 / 1,500 |
| Listing media (avg 4x)    | ~22,000      | ~33,000        | ~66,000     |
| Leads                     | 12,000       | 18,000         | 36,000      |
| Fleet vehicles            | 2,000        | 3,000          | 6,000       |
| Drivers                   | 1,200        | 1,800          | 3,600       |
| Trips                     | 25,000       | 37,500         | 75,000      |
| Fuel logs                 | 20,000       | 30,000         | 60,000      |
| Maintenance jobs          | 4,000        | 6,000          | 12,000      |
| Finance applications      | 4,000        | 6,000          | 12,000      |
| Articles                  | 300          | 450            | 900         |

Lookups: 26 states, 90 freight-focused cities, 10+ body types, fuel/transmission variants, axle configs, and top route corridors.

## How to Run
```bash
# start db stack if needed
make db-up

# migrate + seed (defaults to medium)
make db-seed MODE=medium

# full reset (drop schema, migrate, seed)
make db-reset MODE=small
```

The seed script automatically reflects the current schema, uses UPSERTs for idempotency, and prints a validation/summary report (row counts, coverage, price history coverage, distributions).

## Assumptions
- Database reachable via `DATABASE_URL` in `apps/api/.env` (asyncpg URL supported).
- Timezone-aware timestamps; deterministic UUIDs per record string; RNG seed per mode (small=1337, medium=4242, large=9001).
- Truck-only catalog (LCV/ICV/MCV/HCV) with India manufacturers; no passenger cars.
- Missing domain-specific columns are stored in JSONB extras within `variant_specs.extras` (segment, GVW, payload, axle config, permit/fitness/insurance expiries, application).
- Listing condition details are encoded in `description` and media metadata for visibility during demos.

## Validation
After seeding, the report enforces:
- Minimum counts per domain (manufacturers, variants, listings, leads, fleet, finance, content).
- Listing ranges (year 2008–2026, non-negative km/price).
- Price history coverage ≥150 variants × 20 cities × 18 months.
- Summary metrics: top cities by listings, top manufacturers by variants, average used price/km, year distribution, segment and body type distribution.

## Troubleshooting
- Ensure Postgres extension `pgcrypto` is available (created by migrations).
- If imports fail, confirm `PYTHONPATH` includes the repo root (handled in `scripts/db_seed.sh`).
- For large mode, increase Postgres shared buffers/work_mem as needed; seeding uses batch inserts (2k rows per price chunk).
