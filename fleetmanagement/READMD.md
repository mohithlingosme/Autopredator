# Fleet Management Research Web (Autopredator Fleet Manager) — README

> **Goal:** Build the best **Fleet Management Research + Ops Platform** for commercial fleets (logistics, construction, farm, delivery) — combining **SEO-first research** (guides, comparisons, calculators) with an optional **Fleet Workspace** (dashboards, compliance, maintenance, analytics).

---

## 1) What is the product

### 1.1 Public Research Platform (SEO + Lead Gen)
A research website that helps fleet owners/managers:
- understand fleet tech (GPS/telematics, dispatch, safety, compliance)
- compare vendors + devices
- use calculators + templates to make decisions
- convert via demo/request-quote, report downloads, onboarding

### 1.2 Fleet Workspace (Logged-in SaaS)
A lightweight command center for fleets:
- vehicle/driver registry
- trip + utilization tracking
- fuel + expense logs
- maintenance schedules + downtime insights
- compliance documents + expiry alerts
- reports, exports, and alerts
- integrations (telematics vendors, GPS, fuel cards, ERP) as you scale

> **MVP recommendation:** Start with **Research Platform + basic Workspace** (manual imports + simple reports) → then add real-time tracking + dispatch + predictive AI.

---

## 2) USP (Unique Selling Proposition)

1. **“Research-grade clarity + operational tools”** in one place  
2. **Decision tools** (TCO, fuel, idle, downtime calculators) + templates that fleets actually use  
3. **AI Copilot** that turns fleet data into actions (reduce idle, schedule service, avoid expiry penalties)  
4. **SEO moat**: structured content + schema + internal linking + programmatic pages (vendor/device comparisons)

---

## 3) Features List (Exhaustive)

### 3.1 Public Research (SEO)
- Guides / explainers (Telematics, GPS, Geofencing, Dispatch, Compliance, Safety)
- Glossary + FAQs (schema-ready)
- Vendor directory (Fleet SaaS providers)
- Device directory (GPS trackers, OBD, dashcams, sensors)
- Comparisons:
  - vendor vs vendor
  - device vs device
  - “Best for…” segment pages (Small fleet, Logistics, Construction, Cold chain)
- Pricing + plan breakdowns (where available)
- Case studies + playbooks (industry-wise)
- Templates:
  - vehicle inspection checklist
  - driver SOP
  - trip sheet
  - maintenance schedule template
  - compliance tracker template
- Calculators:
  - Fuel cost & consumption
  - Idle cost
  - Maintenance TCO
  - Downtime cost
  - Route cost estimator
  - Fleet utilization estimator
- Lead capture:
  - demo request
  - report download
  - “Get vendor quotes”
- Newsletter / alerts (policy updates, compliance changes)

### 3.2 Fleet Workspace (SaaS)
- Org setup (multi-branch)
- RBAC (roles: Owner, Manager, Dispatcher, Compliance, Viewer)
- Vehicles
  - metadata, docs, odometer, status, assignments
- Drivers
  - license, training, performance, incidents
- Trips / Operations
  - trip logs (manual/CSV first)
  - route plan (phase 2)
  - dispatch board (phase 2)
- Fuel & Expenses
  - fuel logs, expenses, tolls, reimbursements
- Maintenance
  - service schedules, work orders, parts replacements
- Compliance
  - insurance, permit, fitness, PUC, tax receipts
  - expiry reminders + calendar view
- Safety
  - incidents, violations, driver score (rule-based → ML later)
- Reports
  - utilization
  - cost summaries
  - maintenance spend
  - compliance status
  - driver performance
  - exports (CSV/PDF)
- Alerts (Email/SMS/WhatsApp optional)
  - document expiry
  - maintenance due
  - unusual idle/fuel spikes
  - route deviations (phase 2)

### 3.3 Integrations (Phase 2+)
- Telematics/GPS provider ingestion
- Maps (routing, ETA, geocoding)
- Fuel card data import
- E-challan/permit checks ([ASSUMPTION] depends on availability)
- Webhooks + API clients

---

## 4) Sitemap & Information Architecture

### 4.1 Public Site (SEO)
- `/` Home
- `/solutions`
  - `/solutions/fleet-tracking`
  - `/solutions/fuel-optimization`
  - `/solutions/maintenance`
  - `/solutions/compliance`
  - `/solutions/driver-safety`
- `/research`
  - `/research/guides`
  - `/research/checklists`
  - `/research/templates`
  - `/research/glossary`
  - `/research/faq`
- `/vendors`
  - `/vendors/[vendor-slug]`
  - `/vendors/compare/[vendorA]-vs-[vendorB]`
  - `/vendors/best/[segment]`
- `/devices`
  - `/devices/[device-slug]`
  - `/devices/compare/[deviceA]-vs-[deviceB]`
- `/tools`
  - `/tools/fuel-cost-calculator`
  - `/tools/idle-cost-calculator`
  - `/tools/downtime-cost-calculator`
  - `/tools/maintenance-tco-calculator`
- `/blog`
  - `/blog/[slug]`
- `/case-studies`
- `/pricing` (your plans)
- `/contact` / `/demo`

### 4.2 Workspace (App)
- `/app`
  - `/app/dashboard`
  - `/app/vehicles`
  - `/app/drivers`
  - `/app/trips`
  - `/app/fuel-expenses`
  - `/app/maintenance`
  - `/app/compliance`
  - `/app/safety`
  - `/app/reports`
  - `/app/settings`

---

## 5) All Possible User Journeys (Core)

### 5.1 Research → Compare → Lead (Public)
1. User lands on guide page from Google  
2. Reads benefits + checklist  
3. Uses calculator (idle cost)  
4. Opens comparison (vendors)  
5. Requests demo / vendor quote / downloads report

### 5.2 Vendor Discovery → Decision Support (Public)
1. Browse vendor directory  
2. Filter by fleet size/industry/features  
3. Compare top 3  
4. Download evaluation sheet  
5. Submit “Get quotes”

### 5.3 Onboarding → Basic Fleet Insights (Workspace MVP)
1. Create org → invite users  
2. Add vehicles/drivers  
3. Import trip/fuel CSV  
4. See utilization + fuel summary  
5. Set compliance docs and reminders  
6. Export report

### 5.4 Compliance-first Workflow
1. Add vehicle document types  
2. Upload docs + expiry dates  
3. Dashboard shows upcoming expiries  
4. Alerts + compliance status report

### 5.5 Maintenance Workflow
1. Add service intervals per vehicle  
2. Log work orders and spend  
3. Dashboard shows “due soon” and top spend categories  
4. (Later) predictive downtime alerts

### 5.6 Safety Workflow
1. Log incidents/violations  
2. Driver scoring (rule-based)  
3. Coaching checklist + monthly driver report

---

## 6) Page Blueprints (Exact Sections)

### 6.1 Home
- Hero: value + CTA (demo / tools)
- “Problems we solve” cards
- Top calculators
- Top research guides
- Vendor comparison highlights
- Testimonials / case studies
- Newsletter / contact

### 6.2 Guide Page (SEO Pillar)
- Intro + definition
- Benefits + metrics
- Step-by-step implementation
- Common mistakes
- Checklist download CTA
- FAQ section (schema)
- Related guides + internal links

### 6.3 Vendor Directory
- Filters: fleet size, industry, pricing, features
- Vendor cards with highlights
- “Best for…” sections
- CTA: compare, request quote

### 6.4 Comparison Page (Vendor/Device)
- Sticky compare header
- Feature matrix with “best value” tags
- Pricing & support notes
- Pros/cons + verdict by segment
- CTA: get quotes / demo

### 6.5 Tool/Calculator Page
- Inputs form + results
- Explanation: formula + assumptions
- “How to reduce this cost” guide links
- CTA: download report / demo

### 6.6 App Dashboard (Workspace)
- KPI cards (utilization, fuel, idle, compliance due, maintenance due)
- Alerts panel
- Quick actions (add vehicle, upload docs, import CSV)
- Reports shortcuts

### 6.7 Vehicles Page
- Vehicle list with status + filters
- Vehicle detail:
  - docs, maintenance history, costs, assignments, notes
  - upcoming service & expiries

### 6.8 Reports Page
- Template list (utilization, compliance, maintenance, driver)
- Date range + filters
- Export PDF/CSV
- Schedule reports (phase 2)

---

## 7) Data Blueprint (Entities + Key Fields)

### 7.1 Core (Workspace)
**Organization**
- id, name, industry, timezone, plan, created_at

**User**
- id, org_id, name, email/phone, role, status

**Vehicle**
- id, org_id, reg_no, type, make/model, year, status, odometer, assigned_driver_id

**Driver**
- id, org_id, name, phone, license_no, license_expiry, status

**Trip**
- id, org_id, vehicle_id, driver_id, start_time, end_time, start_loc, end_loc, distance_km, notes, source(manual/csv/telematics)

**FuelTransaction**
- id, org_id, vehicle_id, date, liters, amount, vendor, odometer, source

**Expense**
- id, org_id, vehicle_id, type(toll/repair/other), amount, date, notes

**MaintenanceEvent**
- id, org_id, vehicle_id, date, type(service/repair), cost, odometer, workshop, notes

**ComplianceDocument**
- id, org_id, vehicle_id, doc_type, number, issue_date, expiry_date, file_url, status

**Alert**
- id, org_id, type(expiry/maintenance/fuel), severity, entity_type, entity_id, message, created_at, resolved_at

**Report**
- id, org_id, type, params_json, generated_at, file_url

### 7.2 Public Research (Content)
**Article/Guide**
- id, title, slug, body, category, tags, faq_json, schema_json, published_at

**Vendor**
- id, name, slug, website, pricing_notes, features_json, industries_json, pros_cons_json

**Device**
- id, name, slug, type, specs_json, pricing_notes

**Comparison**
- id, type(vendor/device), left_id, right_id, verdict_json, matrix_json

**CalculatorDefinition**
- id, slug, inputs_json, formula_notes, assumptions_json

---

## 8) Data Collection Strategy (How we gather data)

### 8.1 Workspace Data (Ops)
MVP:
- Manual entry + CSV imports (vehicles, trips, fuel, maintenance, docs)
Phase 2:
- Telematics ingestion from partners (GPS + events)
- Fuel card integration ([ASSUMPTION])
- Automated reminders + report scheduling

### 8.2 Research Data (Content + Vendors)
- Manual research + structured scraping where allowed ([ASSUMPTION: respect robots.txt / TOS])
- Vendor self-serve submissions + verification workflow
- Community feedback / corrections
- Continuous updates:
  - pricing changes
  - new device models
  - feature changes

**Quality gates**
- Source tracking for each vendor claim
- “Last verified” date displayed
- Human approval before publish (especially comparisons)

---

## 9) Backend Blueprint (Services + APIs)

### 9.1 Suggested Architecture
[ASSUMPTION]
- Backend: **FastAPI (Python)** or **NestJS (Node)** (choose one)
- DB: **PostgreSQL**
- Cache: **Redis**
- Search: **OpenSearch/Elasticsearch** (for vendors/articles/devices)
- Async jobs: **Celery/RQ** (Python) or **BullMQ** (Node)
- Optional streaming: **Kafka/Redpanda** (later for telematics)

### 9.2 API Modules (REST)
**Auth**
- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/auth/logout`

**Org & RBAC**
- `GET/POST /api/org`
- `GET/POST /api/users`
- `GET/POST /api/roles`

**Fleet**
- `GET/POST /api/vehicles`
- `GET/POST /api/drivers`

**Trips**
- `GET/POST /api/trips`
- `POST /api/import/trips` (CSV)

**Fuel & Expenses**
- `GET/POST /api/fuel`
- `GET/POST /api/expenses`
- `POST /api/import/fuel` (CSV)

**Maintenance**
- `GET/POST /api/maintenance`
- `GET/POST /api/service-schedule`

**Compliance**
- `GET/POST /api/compliance/docs`
- `GET /api/compliance/expiring?days=30`

**Alerts**
- `GET /api/alerts`
- `POST /api/alerts/:id/resolve`

**Reports**
- `POST /api/reports/generate`
- `GET /api/reports`
- `POST /api/reports/schedule` (phase 2)

**Content (Public)**
- `GET /api/content/articles`
- `GET /api/content/vendors`
- `GET /api/content/compare`
- `GET /api/tools/calculators`

### 9.3 Non-Functional Requirements
- Rate limiting for public endpoints
- Strict RBAC for workspace data
- Audit logs (who changed what)
- Encryption at rest for sensitive docs (phase 2)
- Observability: structured logs + metrics + traces

---

## 10) Frontend Blueprint (SEO + App)

### 10.1 Suggested Frontend
[ASSUMPTION]
- Public site: **Next.js** (SEO + SSR)
- App: Next.js app routes or separate SPA (Vite + React)
- UI: Tailwind + component library
- Analytics: Plausible/PostHog + events

### 10.2 UI Principles
- Fast, minimal, clean
- Comparison tables must be readable on mobile
- Clear CTAs: “Compare”, “Download checklist”, “Request quotes”
- Progressive disclosure in app (don’t overwhelm)

### 10.3 Key UI Components
- Search bar with autosuggest
- Filters (chips + sidebar)
- Compare table with sticky header
- KPI cards + alert list
- CSV import wizard + validation UI
- Report builder + export buttons

---

## 11) AI Features (Mentioned + Possible) + Implementation Plan

### 11.1 MVP AI (Ship Fast)
**A) Fleet Insights Summarizer**
- Input: trips/fuel/maintenance/compliance in last 7/30 days  
- Output: “Top 5 actions to reduce cost / risk this week”

**B) AI Research Assistant (RAG)**
- Chat over your guides, glossary, vendor/device pages
- Helps users understand terms + choose tools

**C) Anomaly Detection (Rule-based first)**
- Fuel spike > threshold
- Idle time spike
- Frequent breakdowns
- Too many compliance expiries coming together

### 11.2 Advanced AI (Phase 2–4)
- Route optimization suggestions
- Dispatch scheduling assistant
- Driver behavior scoring (ML)
- Predictive maintenance (downtime risk)
- “Vendor match” recommender based on fleet profile
- Auto-generate comparison drafts (human approval required)

### 11.3 How we build AI (Practical Stack)
[ASSUMPTION]
- RAG pipeline:
  - Content indexed in vector DB (pgvector / Pinecone / Weaviate)
  - Retrieval + citations in UI
- Internal “human approval loop”:
  - AI drafts → editor review → publish
- Safety:
  - No sensitive location details exposed in AI responses
  - Per-org access control for AI queries

---

## 12) SEO Blueprint (Must-have)
- Clean URL structure (as in sitemap)
- Schema:
  - Article, FAQPage, BreadcrumbList
  - Product-like schema for vendors/devices (careful: don’t misrepresent)
- Internal linking:
  - guide → related guides → vendors → comparisons → tools
- Programmatic SEO:
  - vendor comparisons at scale
  - “best for segment” pages
- Performance:
  - SSR + caching
  - image optimization
  - avoid heavy JS on research pages

---

## 13) File Structure (Recommended Monorepo)

```txt
fleet-research-platform/
  README.md
  apps/
    web/                          # Public SEO site (Next.js)
      src/
        app/                      # routes
        components/
        content/                  # mdx or CMS fetch
        lib/
        styles/
      public/
    dashboard/                    # Fleet workspace UI
      src/
        pages/
        components/
        features/
        api/
        utils/
  services/
    api/                          # Backend (FastAPI/NestJS)
      src/
        modules/
          auth/
          org/
          fleet/
          trips/
          fuel/
          maintenance/
          compliance/
          alerts/
          reports/
          content/
        core/
          db/
          config/
          security/
          jobs/
        main.*
      tests/
    ai/                           # AI services (RAG, scoring, summarizer)
      src/
        rag/
        pipelines/
        prompts/
        evaluators/
  packages/
    ui/                           # shared UI components
    types/                        # shared types (OpenAPI / TS)
    utils/
  infra/
    docker/
    k8s/                          # optional
    terraform/                    # optional
  scripts/
    seed/
    import/
    maintenance/
  docs/
    architecture/
    api/
    product/

## CI/CD and automation
- `CI` workflow (`.github/workflows/ci.yml`): detects `backend/`, `frontend/`, and `php_app/` and only runs matching jobs. Python job installs requirements (if present) and runs Ruff/Black/Mypy/Pytest when installed; Node job installs with npm cache and runs lint/typecheck/build scripts if they exist; PHP job lints files, installs Composer deps, and runs PHPUnit when available. Includes concurrency to cancel duplicate runs and a summary step.
- `CodeQL` workflow (`.github/workflows/codeql.yml`): security analysis for Python and JavaScript on pushes/PRs to `main`/`develop` plus a weekly scan.
- `Docker Build and Push` (`.github/workflows/docker-build-push.yml`): on pushes to `main` or tags like `v1.0.0`, logs into Docker Hub and builds/pushes images for areas with a `Dockerfile` (`backend`, `frontend`) tagged with `:latest` and `:<github.sha>`.
- `Deploy` workflow (`.github/workflows/deploy.yml`): on push to `main`, SSH into the VPS and runs `docker compose -f docker-compose.prod.yml up -d --remove-orphans` after hard-resetting to `origin/main`; fails early if `docker-compose.prod.yml` is missing in `DEPLOY_PATH`.
- Dependabot (`.github/dependabot.yml`): weekly updates for pip (`/backend`), npm (`/frontend`), composer (`/php_app`), and GitHub Actions (`/`).
- Production docker compose template (`docker-compose.prod.yml`): placeholders using `YOUR_DOCKERHUB/autopredator-backend` and `YOUR_DOCKERHUB/autopredator-frontend`; adjust image names, ports, and env before deploying.

### Required GitHub secrets
- Docker Hub: `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`.
- Deploy: `SSH_HOST`, `SSH_USER`, `SSH_PRIVATE_KEY`, `DEPLOY_PATH` (path on the VPS that already has this repo).

### How to trigger
- Docker images build/push: any push to `main` or tags matching `v*` (e.g., `v1.0.0`).
- Deploy: automatic on pushes to `main` after secrets are set and `docker-compose.prod.yml` exists in `DEPLOY_PATH`.
