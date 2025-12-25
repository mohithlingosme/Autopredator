# Autopredator — CV/HV + Farm + Construction Vehicle Research Platform (Buyer-First)

> A fast, SEO-first research website where buyers can **discover → filter → compare → calculate TCO/EMI → shortlist → request quotes** for **Commercial Vehicles (LCV/ICV/MHCV/Buses)**, **Farm Vehicles (tractors + implements)**, and **Construction Equipment (earthmovers, loaders, cranes, etc.)**.

---

## 1) What is the product?

Autopredator (CV/HV/Farm/Construction module) is a **decision platform** for people who buy vehicles for **work and earnings**, not just lifestyle.
It helps users answer:
- Which vehicle fits my **load / route / terrain / daily km / usage hours**?
- What’s the **real cost** (fuel + maintenance + tyres + insurance + depreciation)?
- What’s the best **variant/config** and **best value** option?
- Where can I get **quotes / dealers / finance** quickly?

**Primary outputs:**
- Shortlists + comparisons
- Total Cost of Ownership (TCO) views
- Quote requests & dealer leads
- Trust signals (reviews, issues, price trends, documents)

---

## 2) Feature list (All features to provide)

### 2.1 Core Research Platform (MVP)
- **Category discovery**
  - Commercial: LCV / ICV / M&HCV / Buses
  - Farm: Tractors / Harvesters / Implements
  - Construction: Excavators / Backhoe loaders / Cranes / Tippers / Loaders / Rollers
- **Powerful filters**
  - Price, fuel, emission norm, transmission
  - GVW / payload / axle configuration (CV)
  - HP / PTO / hydraulics / implement support (Farm)
  - Operating weight / bucket capacity / reach / lift capacity (Construction)
- **Model pages**
  - Overview, applications, pros/cons, key specs, variants table
- **Variant/Config pages**
  - Full spec sheet, pricing, feature set, downloads, quote CTA
- **Compare (side-by-side)**
  - Compare models/variants
  - Highlight “best value” based on selected priority
  - Shareable compare URLs
- **Tools**
  - EMI calculator
  - TCO calculator (fuel, maintenance, tyres, insurance, depreciation)
  - Fuel cost estimator
  - Usage-based cost (₹/km for CV, ₹/hour for equipment)
- **Shortlist**
  - Save vehicles/variants and share shortlist
- **Lead capture**
  - Request quote / dealer contact / finance interest

### 2.2 Trust + Community (Phase 2)
- Expert reviews + user reviews
- Q&A per model/variant
- Known issues / common complaints (structured)
- Ownership cost reports (crowdsourced + verified)
- Price trends + “price change alerts”
- Recently viewed + search history
- Downloadable spec packs (PDF) for procurement

### 2.3 Ecosystem Expansions (Phase 3+)
- Dealer & service network directory
- Finance/Insurance marketplace integration
- Fleet dashboard (for business buyers)
- Compliance helper (permits/renewals reminders)
- Auction/resale signals (later)
- Forum/community for operators & contractors

---

## 3) Sitemap & Information Architecture

### 3.1 Top-level sitemap
- `/` Home
- `/vehicles/`
  - `/vehicles/commercial/`
    - `/vehicles/commercial/lcv/`
    - `/vehicles/commercial/icv/`
    - `/vehicles/commercial/mhcv/`
    - `/vehicles/commercial/buses/`
  - `/vehicles/farm/`
    - `/vehicles/farm/tractors/`
    - `/vehicles/farm/implements/`
  - `/vehicles/construction/`
    - `/vehicles/construction/excavators/`
    - `/vehicles/construction/backhoe-loaders/`
    - `/vehicles/construction/cranes/`
    - `/vehicles/construction/loaders/`
    - `/vehicles/construction/tippers/`
- `/brands/`
  - `/brands/{brand}/`
- `/models/`
  - `/models/{brand}-{model-slug}/`
- `/variants/`
  - `/variants/{variant-slug}/`
- `/compare/`
  - `/compare/{id1}-vs-{id2}/`
- `/tools/`
  - `/tools/emi/`
  - `/tools/tco/`
  - `/tools/fuel-cost/`
  - `/tools/operating-cost/`
- `/guides/`
  - `/guides/{topic}/`
- `/reviews/`
- `/dealers/`
- `/quotes/` (quote request flow)
- `/account/` (login, shortlist, alerts)

### 3.2 Information architecture (content + entities)
**Vehicle Catalog**
- Brand → Model → Variant/Config
- Model belongs to a Segment/Category
- Variant has specs, features, price history, media, documents

**Decision Support**
- Applications/use-cases
- TCO inputs and calculators
- Reviews, issues, Q&A

**Monetization Layer**
- Dealers, quotes, finance leads

---

## 4) All possible user journeys (Golden flows)

### 4.1 Buyer research journey (standard)
1. Landing on category page (SEO)
2. Apply filters (payload/GVW/price/fuel)
3. Open 2–4 models
4. Add to compare
5. Use TCO/EMI to pick best value
6. Shortlist
7. Request quotes (dealer/finance)

### 4.2 “I know what I want” journey
1. Search brand+model
2. Variant table → pick config
3. View price + EMI
4. Request quote

### 4.3 Commercial fleet journey (ops-driven)
1. Choose application (city logistics / highway / mining / construction tipper)
2. Filter by payload / axle / mileage / service interval
3. Compare uptime signals + TCO
4. Download spec pack
5. Request quote for bulk

### 4.4 Farmer journey (agri-fit)
1. Select land size + crop type + soil + budget
2. Tractor recommendations
3. Check implement compatibility
4. Finance/subsidy guidance (Phase 2)
5. Shortlist + quote request

### 4.5 Construction contractor journey
1. Select equipment type + project type
2. Filter by capacity/weight/reach
3. Compare ₹/hour operating cost
4. Lease vs buy guidance (Phase 2)
5. Request quote / rental leads (Phase 3)

### 4.6 Return user / retention
- Alerts: price drop, new variant, new model
- Recently viewed & saved comparisons
- Ownership cost updates

---

## 5) Page blueprints (sections + components)

### 5.1 Home
- Hero search (category + keyword)
- Trending segments (LCV, Tippers, Tractors, Excavators)
- “Best for” blocks (best mileage, best payload value)
- Tools shortcuts (TCO/EMI)
- Latest price updates + guides
- Trust metrics (reviews count, verified reports)

### 5.2 Category Listing Page
- SEO intro + FAQs
- Filter rail (sticky)
- Result cards:
  - Key specs (payload/GVW/HP/capacity)
  - Price range
  - Compare + Save
- Pagination + internal links to guides

### 5.3 Brand Page
- Brand overview
- Models by category
- Service network (if available)
- Brand reviews summary
- Popular comparisons

### 5.4 Model Page (most important)
- Hero: price range, use-cases, highlights
- Key specs grid
- Variants table (filterable)
- Competitors (“Similar vehicles”)
- Ownership snapshot (fuel cost + service interval)
- Reviews + common issues
- FAQs + Q&A
- Downloads (brochure/spec sheet)
- CTA: Compare / Shortlist / Quote

### 5.5 Variant/Config Page
- Variant hero + exact pricing (with region selector)
- Full spec table (expandable)
- Feature list
- EMI widget
- TCO quick estimator
- Quote CTA + dealer listing
- Similar variants

### 5.6 Compare Page
- Compare selector (search + add/remove)
- Sticky header with key metrics
- Sections:
  - Price & EMI
  - Capability (payload/GVW/HP/capacity)
  - Running cost (TCO)
  - Dimensions
  - Warranty/service interval
- “Best value” highlight (based on user priority)
- Share compare link

### 5.7 Tools Pages
- EMI: amount/tenure/interest + breakdown
- TCO: inputs + assumptions + downloadable report
- Fuel cost: km/day, mileage, fuel price
- Operating cost: ₹/km (CV) / ₹/hour (equipment)

### 5.8 Guides / Blog
- Programmatic “best X for Y” pages
- Explainers: GVW, payload, axle config, PTO, hydraulics, etc.
- Ownership tips

---

## 6) Data blueprint (entities + fields + relationships)

### 6.1 Core entities
- `manufacturers` (id, name, country, website)
- `brands` (id, name, manufacturer_id, logo_url)
- `categories` (id, name, parent_id)  
  Examples: Commercial→MHCV→Tippers
- `models` (id, brand_id, category_id, name, launch_year, status, summary, slug)
- `variants` (id, model_id, name, slug, status, launch_date, discontinuation_date)

### 6.2 Specs (normalized)
- `engines` (variant_id, displacement_cc, hp, torque_nm, fuel_type, emission_norm)
- `transmissions` (variant_id, type, gears, clutch)
- `dimensions` (variant_id, length, width, height, wheelbase, ground_clearance)
- `cv_specs` (variant_id, gvw_kg, payload_kg, axle_config, body_type, gradeability)
- `farm_specs` (variant_id, pto_hp, lift_capacity_kg, hydraulics_type, implements_supported)
- `construction_specs` (variant_id, operating_weight_kg, bucket_capacity_m3, reach_m, lift_capacity_t)

### 6.3 Pricing + trends
- `prices` (id, variant_id, region_id, ex_showroom, on_road_estimate, as_of_date, source)
- `price_history` (variant_id, region_id, date, price, change_reason)

### 6.4 Features + media + docs
- `features` (id, name, group)
- `variant_features` (variant_id, feature_id, availability, notes)
- `media` (entity_type, entity_id, type, url, caption)
- `documents` (entity_type, entity_id, doc_type, url, source)

### 6.5 Trust layer
- `reviews` (id, entity_type, entity_id, rating, title, body, author_type, verified, created_at)
- `issues` (id, model_id, issue_type, severity, description, evidence_links)
- `qa` (id, model_id, question, answer, answered_by, created_at)

### 6.6 Monetization layer
- `dealers` (id, name, brand_ids, region_id, contact, address, geo)
- `quote_requests` (id, user_id, variant_id, region_id, phone/email, usage_notes, status)

### 6.7 Relationships (quick view)
- Brand 1—N Models
- Model 1—N Variants
- Variant 1—1 Specs groups (engine, transmission, etc.)
- Variant 1—N Prices (by region/time)
- Model/Variant 1—N Reviews, Q&A
- Variant N—N Features

---

## 7) Data collection strategy (how we build + maintain data)

### 7.1 Sources (Phase 1: reliable)
- OEM brochures/spec sheets
- Official price lists / press releases
- Dealer-provided price ranges (tagged as estimated)
- Reputable automotive publications (for reviews)

### 7.2 Collection pipeline
1. **Seed list**
   - Top 10–20 models per category (LCV, Tippers, Tractors, Excavators)
2. **Structured extraction**
   - Convert brochures → normalized fields (manual initially)
3. **Validation rules**
   - Required fields per category (CV: payload/GVW, Farm: PTO/lift, Construction: weight/capacity)
4. **Versioning**
   - Store source URL + “as_of_date”
5. **Price update cadence**
   - Monthly scan + change logs

### 7.3 Human approval loop (important)
- Any automated extraction creates a “pending” record
- Admin reviews diffs → approves → publish
- Keep “last updated” metadata on pages

### 7.4 Crowdsourcing (Phase 2)
- Ownership cost reports (mileage/maintenance)
- Real-world performance (fuel economy / uptime)
- Verification: invoice upload optional + reputation scoring

---

## 8) Backend + APIs + Frontend

## 8.1 System architecture (high-level)
- **Frontend**: Next.js/React (SSR/SSG for SEO pages)
- **Backend**: FastAPI (or Node) for APIs + admin + ingestion
- **DB**: Postgres (catalog + pricing + reviews)
- **Search**: Postgres full-text first → later Elasticsearch/Meilisearch
- **Cache**: Redis (hot pages, compare results)
- **Storage**: S3-compatible (media/docs)
- **CDN**: Cloudflare (assets + caching)
- **Analytics**: events (search, compare, quote submits)

## 8.2 API endpoints (MVP)
### Catalog
- `GET /api/categories`
- `GET /api/brands`
- `GET /api/models?category=...&brand=...`
- `GET /api/models/{slug}`
- `GET /api/variants/{slug}`

### Search & Filters
- `GET /api/search?q=...`
- `GET /api/filters?category=...` (returns filter metadata + ranges)
- `GET /api/listings?category=...&filters=...&sort=...`

### Compare
- `GET /api/compare?variant_ids=1,2,3`

### Tools
- `POST /api/tools/emi`
- `POST /api/tools/tco`
- `POST /api/tools/fuel-cost`
- `POST /api/tools/operating-cost`

### Trust
- `GET /api/reviews?entity_type=model&entity_id=...`
- `POST /api/reviews` (optional Phase 2)
- `GET /api/issues?model_id=...`
- `GET /api/qa?model_id=...`

### Leads
- `POST /api/quotes` (create quote request)
- `GET /api/dealers?brand=...&region=...`

### User (optional MVP-lite)
- `POST /api/auth/login`
- `GET /api/shortlist`
- `POST /api/shortlist/add`
- `POST /api/shortlist/remove`

## 8.3 Frontend pages (Next.js)
- `/vehicles/[vertical]/[category]`
- `/brands/[brand]`
- `/models/[model]`
- `/variants/[variant]`
- `/compare/[...slugs]`
- `/tools/[tool]`
- `/guides/[slug]`
- `/quotes`

---

## 9) AI features (mentioned + additional) + implementation plan

### 9.1 MVP AI (low-risk, high value)
1. **Recommendation Assistant**
   - Inputs: budget, payload/GVW or acreage/crop or project type
   - Output: ranked list with reasons + trade-offs
   - Implementation: rules + scoring first, then ML ranking later

2. **Compare Explainer (NLP)**
   - “Which is better for city deliveries 120km/day?”
   - Implementation: prompt on structured compare JSON → narrative output

3. **Review Summarizer + Sentiment**
   - Summarize pros/cons from reviews + common issues
   - Implementation: LLM summarization + simple sentiment scoring

4. **Spec Normalizer**
   - Convert messy brochure text into structured fields
   - Implementation: extraction prompts + validation rules + human approval

### 9.2 Phase 2 AI
- **Price trend insights**
  - Detect price changes + summarize what changed
- **Resale estimator**
  - Start heuristic; later ML with market data
- **“Best value” scoring**
  - Weighted scoring based on user priority sliders (mileage vs payload vs cost)

### 9.3 Phase 3 AI (fleet-grade)
- Predictive maintenance (requires telematics data)
- Route optimization insights
- Driver behavior scoring (if integrated)

### 9.4 AI safety + trust
- Every AI answer shows:
  - assumptions used
  - data freshness (“as of” date)
  - sources when available
- Human approval loop for any AI-generated specs/prices

---

## 10) USP (Why this will win)

1. **Work-first decision support** (TCO + operating cost), not just brochure specs  
2. **Variant/config clarity** (buyers pick the exact right configuration)  
3. **Vertical specialization**
   - CV: payload/GVW/axle + ₹/km economics
   - Farm: PTO/lift/implements + seasonal finance logic
   - Construction: ₹/hour productivity logic
4. **Trust layer**
   - issues, ownership reports, price trends, downloadable packs
5. **SEO-first architecture**
   - programmatic pages for long-tail “best X for Y” searches

---

## 11) File structure (suggested monorepo)

---

## 12) CI/CD, Docker, and Ops

- **Workflows**: CI (`.github/workflows/ci.yml` for backend/frontend/PHP), Docker build & push to GHCR (`.github/workflows/docker-build-push.yml`), SSH deploy via docker compose (`.github/workflows/deploy-vps.yml`), CodeQL SAST (`.github/workflows/codeql.yml`), and secret scanning (`.github/workflows/security.yml` with gitleaks). Automated dependency updates run via `.github/dependabot.yml`.
- **Secrets required (GitHub)**: `VPS_HOST`, `VPS_USER`, `VPS_SSH_KEY` (private key with deploy access), `APP_DIR` (path to repo on the server). `GITHUB_TOKEN` is used for GHCR pushes by default.
- **Run checks locally**:
  - Backend: `cd backend && python -m venv .venv && . .venv/bin/activate && pip install -r requirements.txt && uvicorn app.main:app --reload`; tests if added: `pytest -q`.
  - Frontend: `cd frontend && npm install && npm run lint && npm run test && npm run build`.
  - Docker: `docker build -t local-backend ./backend` and `docker build -t local-frontend ./frontend`.
- **Deploy (server prerequisites)**: Install Docker Engine + Compose plugin, create `.env` in repo root for backend app settings, log in to GHCR (`echo $PAT | docker login ghcr.io -u USERNAME --password-stdin` with a PAT that has `read:packages`), set `BACKEND_IMAGE`/`FRONTEND_IMAGE` or use the defaults in `docker-compose.prod.yml`, then run `docker compose -f docker-compose.prod.yml pull` followed by `docker compose -f docker-compose.prod.yml up -d --remove-orphans`.

