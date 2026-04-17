# TODO.md — Update CarResearchWeb to work with `autopredator_cars` (new DB constraints)

> Goal: Make **CarResearchWeb (frontend + backend)** work cleanly with the latest `autopredator_cars` schema and its stricter constraints:
> - NOT NULL slugs, NOT NULL image_url, NOT NULL region/as_of_date
> - cascade deletes (brand→models→variants) if you applied the hardening patch
> - only one thumbnail per variant
> - unique keys everywhere (idempotent imports)
> - latest ex-showroom view (`v_variant_latest_exshowroom`) if present

---

## 0) Prep

- [ ] Create a new branch: `db-autopredator-cars-hardening`
- [ ] Add `.env.example` for both frontend and backend (if not already)
- [ ] Ensure `.gitignore` includes `.env`, dumps, `/dist`, `/node_modules`, etc.

---

## 1) Database: migrate + enforce constraints

### 1.1 Apply DB hardening migration (if not applied yet)
- [x] Add a folder: `db/migrations/`
- [x] Create: `db/migrations/2026-01-08_autopredator_cars_hardening.sql`
  - Includes:
    - Slug backfill + `NOT NULL` on `brands.slug`, `models.slug`, `variants.slug`
    - `images.image_url NOT NULL`
    - `variant_price_history.region NOT NULL`, `as_of_date NOT NULL`
    - brand→models and model→variants `ON DELETE CASCADE`
    - enforce single thumbnail per variant
    - drop redundant indexes (`idx_variants_model` and `uq_variant_feature`)

### 1.2 Add DB verification script
- [x] Create: `db/checks/verify_constraints.sql`
  - Checks:
    - no null/empty slugs
    - no null/empty image_url
    - `variant_price_history` has region + as_of_date
    - no variant has >1 thumbnail
    - view exists (optional)

### 1.3 Schema Analysis: Variant-Specific Technical Specifications
- [x] **Analysis Complete** (2025-01-20): Reviewed `docs/db-schema-complete.sql` and `data/new_carset.json`
  - Finding: **Schema is already variant-specific** ✅
  - The `vehicle_specs` table has `variant_id` as a UNIQUE foreign key
  - All technical specs (torque, power, dimensions, displacement) are linked to specific variants
  - **No ALTER TABLE commands needed** - schema correctly enforces 1:1 variant-to-specs relationship

### 1.4 Seed strategy update (idempotent)
- [ ] Ensure all seeds use UPSERT patterns:
  - `features(name)` UNIQUE → `INSERT ... ON DUPLICATE KEY UPDATE ...`
  - variants unique `(model_id,fuel,transmission,variant_name)`
  - price unique `(variant_id, price_type, region, as_of_date)`
  - image unique `(variant_id, image_url)`
- [ ] Standardize region codes:
  - Default `IN` (or `KA`, etc) but be consistent
- [ ] Standardize price_type:
  - Always store `ex_showroom` only (per project rule)

---

## 2) Backend: connect to `autopredator_cars` and expose stable APIs

### 2.1 Config + DB client
- [x] Backend `.env` variables:
  - `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASS`, `DB_NAME=autopredator_cars`
- [x] Add DB connection module with pooling + reconnect:
  - `src/db/index.(js|ts|py|php)` (match your stack)
- [x] Add a health endpoint:
  - `GET /api/health` returns DB ok + version

### 2.2 Data model mapping (backend layer)
- [ ] Add repository/service layer for:
  - brands
  - models
  - variants
  - features + variant_feature_values
  - images
  - latest price (prefer view if exists)
- [ ] Add strict input validators for all write endpoints:
  - slug required
  - image_url required
  - price history requires region + as_of_date

### 2.3 API endpoints (minimum set)
- [ ] `GET /api/brands`
- [ ] `GET /api/brands/:brandSlug/models`
- [ ] `GET /api/models/:modelSlug/variants`
- [ ] `GET /api/variants/:variantSlug`
  - include:
    - latest ex_showroom price (from view or query)
    - images (thumbnail + gallery)
    - feature groups + values
- [ ] `GET /api/search`
  - params: `q`, `brand`, `fuel`, `transmission`, `minPrice`, `maxPrice`
- [ ] `GET /api/features` (optional for filters)

### 2.4 “Latest price” logic (important)
- [ ] Prefer using view `v_variant_latest_exshowroom` if present
- [ ] Else implement query:
  - select price row with max(`as_of_date`) for `ex_showroom` + region
- [ ] Ensure API never returns on-road/other pricing types

### 2.5 Images: enforce single thumbnail behavior
- [ ] Backend rule:
  - when setting thumbnail:
    1) set all variant images `is_thumbnail=0`
    2) set selected `is_thumbnail=1`
- [ ] Add admin-only endpoint (optional):
  - `PATCH /api/variants/:variantSlug/images/:imageId/thumbnail`

### 2.6 Error handling
- [ ] Centralize DB error mapping:
  - `ER_DUP_ENTRY` → 409 conflict
  - FK failures → 400 with friendly message
- [ ] Add request logging + correlation id

---

## 3) Frontend: update UI to match DB + new API contracts

### 3.1 Routing (slug-based)
- [x] Use slugs everywhere:
  - `/brands/:brandSlug`
  - `/models/:modelSlug`
  - `/variants/:variantSlug`

### 3.2 Core pages
- [ ] Brands list page
- [ ] Brand models page
- [ ] Model variants list page
  - show: variant name, fuel, transmission, latest ex_showroom price
- [ ] Variant detail page
  - Price (latest ex_showroom)
  - Image gallery + thumbnail
  - Features grouped by category
  - Sources if present (optional)

### 3.3 Filters (from real columns)
- [x] Filter variants by:
  - fuel
  - transmission
  - price range
  - feature presence (optional)
- [x] Add “Only ex-showroom” label (hard-coded rule)

### 3.4 UX safeguards
- [ ] If price missing, show “Price not available” (don’t crash)
- [ ] If images missing, show placeholder
- [ ] If features missing, show empty state

---

## 4) New feature support (EV / ADAS / Connectivity / Hybrid / CNG / Fuel-Cell)

### 4.1 Feature master list
- [ ] Add the missing feature insert script into `db/seeds/features_missing_2026.sql`
  - includes EV utilities (V2L/V2V/etc), granular ADAS (TSR/BVM/etc), advanced connectivity, etc.
- [ ] Confirm all names are canonical (no duplicates like “Wireless CarPlay” vs “Wireless Apple CarPlay”)

### 4.2 Feature tagging (recommended)
- [ ] Add tables (optional but recommended):
  - `feature_tags(id, name UNIQUE)`
  - `feature_tag_map(feature_id, tag_id)` unique
- [ ] Tag examples:
  - `EV`, `ADAS`, `CONNECTIVITY`, `COMFORT`, `EXTERIOR`, `HYBRID`, `CNG`, `FUEL_CELL`

### 4.3 Variant feature mapping strategy
- [ ] Add utilities to map features by:
  - brochure source_id + parsing rules
  - or manual curated mapping per model/variant

---

## 5) Testing & Validation (make it “green”)

### 5.1 Backend tests
- [ ] Unit tests for:
  - slug queries
  - latest price logic
  - thumbnail enforcement
- [ ] Integration tests using test DB:
  - brands/models/variants query paths
  - constraint violations return proper HTTP codes

### 5.2 Frontend tests
- [ ] Smoke tests:
  - brands load
  - model variants load
  - variant detail renders without crashing

### 5.3 DB checks in CI (optional)
- [ ] Add workflow step:
  - run `verify_constraints.sql` against a CI database container

---

## 6) Documentation

- [ ] Update `README.md` inside `CarResearchWeb/`:
  - setup steps
  - env vars
  - migration order
  - seed strategy (idempotent)
  - API endpoints
- [ ] Add `docs/db.md`:
  - constraint summary
  - “do’s and don’ts” for imports (slugs, image_url, as_of_date, region)

---

## 7) Deployment checklist

- [ ] Ensure migrations run before app deploy
- [ ] Confirm DB user has required privileges:
  - SELECT/INSERT/UPDATE on tables
  - CREATE VIEW (if you recreate views)
- [ ] Add runtime config for production DB
- [ ] Add basic rate limiting + CORS policy

---

## Acceptance Criteria

- [ ] App boots (frontend + backend) using `autopredator_cars`
- [ ] Brands → Models → Variants navigation works via slugs
- [ ] Variant page shows:
  - latest **ex_showroom** price
  - images (thumbnail + gallery)
  - features
- [ ] No duplicate insert errors during seeds (idempotent)
- [ ] DB constraints pass `verify_constraints.sql`
