# Development_plan.md
*(Autopredator – Commercial/Heavy/Construction/Farm Vehicle Research Platform | India-only)*

> Goal: This document is a **step-by-step “how to build the app” manual**. If someone reads this from top to bottom, they should be able to set up, build, test, and deploy the product—even if they’re new to software.

---

## 0) What are we building? (Plain-English)

We are building a **vehicle research website/platform** for India focused on:

- **Commercial Vehicles (CVs)**: trucks, tippers, pickups, LCVs, ICVs, buses
- **Heavy Vehicles (HV)**: heavy trucks, haulage, heavy-duty
- **Construction Equipment**: excavators, loaders, backhoe, cranes, compactors
- **Farm Vehicles**: tractors, harvesters, implements

Users can:

- Search vehicles (by brand, model, variant, price, payload, engine, etc.)
- Open a model page and see specs, features, images, pros/cons, and “best use-case”
- Compare vehicles side-by-side
- Shortlist/favorites
- Use calculators (EMI, TCO, payload, fuel cost, resale, ROI)
- Read guides/news/reviews (content system)
- For businesses/fleets: keep a portfolio/fleet wishlist and export reports

Admins can:

- Add/edit models/variants/specs (CMS/admin panel)
- Approve AI-generated content drafts
- Trigger data imports and validation checks

AI assists with:

- Auto-writing content drafts from structured specs
- Normalizing messy spec data
- Detecting missing fields + suggesting improvements
- Answering “Which vehicle is best for my use-case?” with explainable results

---

## 1) Product boundaries (Important)

### India-only rules
- All currency in **INR**
- Local taxes/fees assumptions (state differences supported via settings)
- Units: metric (km/l, tonnes, mm, cc) and consistent conversions

### “Truth-first” policy
- Specs and prices must have **sources + timestamps**
- AI output is always **draft until approved** (no hallucinated claims)

---

## 2) Roles & who builds what (Even for a small team)

- **Product Owner (You)**: decisions, approvals, roadmap
- **Backend Developer**: APIs, DB, auth, admin
- **Frontend Developer**: UI pages, search, compare, UX
- **Data Engineer**: data ingestion, cleaning, validation
- **AI Engineer (optional at MVP)**: AI prompts, retrieval, approval workflow
- **QA/Test Engineer**: test cases, automation, regression checks
- **DevOps**: CI/CD, Docker, deploy, monitoring

If you are solo: build in this order → **DB → APIs → pages → data import → AI drafts → polish**.

---

## 3) Recommended tech stack (MVP + scalable)

You can build this as a **monolith** first, then split later.

### MVP stack (recommended)
- **Frontend**: Next.js (React) + Tailwind
- **Backend**: FastAPI (Python)
- **Database**: PostgreSQL
- **Search**: Meilisearch (easy) or Elasticsearch/OpenSearch (advanced)
- **Cache**: Redis
- **Storage**: S3-compatible (MinIO locally, AWS S3/Wasabi in prod)
- **Background jobs**: Celery/RQ + Redis
- **Auth**: JWT + refresh tokens (or NextAuth if you prefer)
- **CI/CD**: GitHub Actions
- **Deployment**: Docker + docker-compose (MVP), later Kubernetes

### Why this stack?
- Fast to build, strong ecosystem, good for data and AI workflows
- Easy scaling (search + cache + jobs)

> If your current repo is PHP-based: you can still follow the same plan conceptually, but the API and job layer will differ.

---

## 4) High-level architecture (simple picture)

```
Browser (User)
   |
   v
Frontend (Next.js)
   |
   v
Backend API (FastAPI)
   |
   +--> PostgreSQL (truth data)
   +--> Search Index (Meilisearch/ES)  [fast search]
   +--> Redis (cache + sessions + queues)
   +--> Object Storage (images, docs)
   +--> AI Services (content drafts + Q&A)
   +--> Observability (logs/metrics)
```

---

## 5) Repository structure (what folders mean)

Example structure:

```
autopredator/
  apps/
    web/                  # Next.js frontend
    api/                  # FastAPI backend
  packages/
    shared/               # shared types, helpers, constants
    ui/                   # shared UI components
  infra/
    docker/               # docker-compose, Dockerfiles
    k8s/                  # optional later
  data/
    seeds/                # seed datasets
    imports/              # raw data files (CSV/JSON)
    validators/           # validation scripts
  docs/
    Development_plan.md   # this file
    api_contract.md       # API contract reference
  .github/
    workflows/            # CI pipelines
  .env.example
  README.md
```

---

## 6) Local setup (step-by-step)

### 6.1 Install prerequisites
- Git
- Node.js (LTS)
- Python 3.11+
- Docker Desktop
- VS Code (recommended)

### 6.2 Clone repo
```bash
git clone <your-repo-url>
cd autopredator
```

### 6.3 Create environment file
Copy `.env.example` → `.env` and fill values.

Example `.env` (local):
```env
# Database
DATABASE_URL=postgresql+psycopg://postgres:postgres@localhost:5432/autopredator

# Redis
REDIS_URL=redis://localhost:6379/0

# Search
MEILI_URL=http://localhost:7700
MEILI_MASTER_KEY=dev_master_key

# Storage
S3_ENDPOINT=http://localhost:9000
S3_ACCESS_KEY=minioadmin
S3_SECRET_KEY=minioadmin
S3_BUCKET=autopredator

# Auth
JWT_SECRET=change_me
JWT_REFRESH_SECRET=change_me_too
```

### 6.4 Start infrastructure (DB/Redis/Search/MinIO)
```bash
docker compose -f infra/docker/docker-compose.yml up -d
```

### 6.5 Backend setup
```bash
cd apps/api
python -m venv .venv
# Windows: .venv\Scripts\activate
source .venv/bin/activate
pip install -r requirements.txt
```

Run API:
```bash
uvicorn app.main:app --reload --port 8000
```

### 6.6 Frontend setup
```bash
cd apps/web
npm install
npm run dev
```

Open:
- Web: http://localhost:3000
- API docs: http://localhost:8000/docs

---

## 7) Database design (the “truth layer”)

### 7.1 Core entities (human explanation)

- **Manufacturer**: Tata, Ashok Leyland, Mahindra…
- **Model**: Tata Ace, Leyland Dost…
- **Variant**: specific configuration (engine + cabin + axle + payload)
- **Specs**: engine, torque, GVW, payload, dimensions, tyres
- **Price**: ex-showroom, on-road, city/state variations
- **Images**: photos, brochures, 360s
- **Features**: AC, ABS, telematics, etc.
- **Content**: reviews, guides, FAQs, comparisons
- **User data**: accounts, shortlists, recently viewed
- **Admin data**: approvals, audit logs

### 7.2 Minimal schema (MVP tables)
- manufacturers
- models
- variants
- variant_specs
- features
- variant_features
- price_history
- images
- content_posts
- users
- shortlists
- comparisons
- audit_logs

> Add more later: dealer networks, service centers, resale index, finance partners.

### 7.3 Data rules (quality)
- Every price/spec must store:
  - source (URL/file/dealer input)
  - captured_at timestamp
  - confidence score (manual=high, scraped=medium)
- No deletion of important rows; use “inactive” flags + history tables.

---

## 8) Backend API (what endpoints exist)

Base: `/api/v1`

### 8.1 Public (no login)
- `GET /manufacturers`
- `GET /models?category=cv&manufacturer=tata&query=ace`
- `GET /models/{model_id}`
- `GET /variants?model_id=...`
- `GET /variants/{variant_id}`
- `GET /compare?variant_ids=1,2,3`
- `GET /content?type=guide&query=payload`
- `GET /calculators/emi` (metadata)
- `POST /calculators/emi/compute`

### 8.2 User (login)
- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`
- `GET /me`
- `POST /shortlist/{variant_id}`
- `DELETE /shortlist/{variant_id}`
- `GET /shortlist`
- `POST /recently-viewed`

### 8.3 Admin
- `POST /admin/import` (upload CSV/JSON)
- `POST /admin/search/reindex`
- `POST /admin/content/generate-draft`
- `POST /admin/content/{id}/approve`
- `POST /admin/variants/{id}` (edit)
- `GET /admin/audit`

---

## 9) Frontend pages (what the user sees)

### 9.1 Main pages (MVP)
- Home
- Search results
- Manufacturer page
- Model page
- Variant page
- Compare page
- Shortlist page
- Calculators hub + calculators pages
- Content hub (guides/reviews/news)
- Login/Register

### 9.2 Page blueprint (example: Variant page)
Sections:
1. Title + badges (GVW, payload class, fuel type)
2. Price (with city/state selector + last updated)
3. Key specs highlight cards (engine, torque, mileage, payload)
4. Feature list (filterable)
5. Images + brochure download
6. Pros/Cons + “best for” use case
7. Similar alternatives
8. Disclaimer + sources

---

## 10) Search (how “fast search” works)

### 10.1 Why search index?
Database is great for truth, but slow for text + filters at scale.

### 10.2 Workflow
1. Data stored in PostgreSQL
2. A “reindex job” pushes key fields to Meilisearch/ES
3. Search queries hit Meilisearch/ES
4. Results show IDs → fetch full details from API/DB

### 10.3 What fields are indexed?
- manufacturer_name
- model_name
- variant_name
- category (CV/HV/Construction/Farm)
- payload/GVW ranges
- fuel type
- price range
- city/state

---

## 11) Data ingestion & updates (how you get data)

### 11.1 Sources (India-friendly)
- OEM brochures (PDFs)
- OEM websites (manual entry, not risky scraping)
- Dealer quotes (verified)
- User submissions (flagged + reviewed)

### 11.2 Import pipeline (MVP)
1. Admin uploads CSV/JSON
2. Validator checks:
   - required fields present
   - numeric ranges valid
   - duplicates
3. Importer writes to DB
4. Reindex job updates search

### 11.3 Validation rules (examples)
- GVW must be > 0
- payload <= GVW
- price must be in INR and positive
- model must link to manufacturer

---

## 12) Content system (guides/reviews)

### 12.1 Content types
- guide (how-to)
- review (model/variant)
- comparison (A vs B)
- news/updates

### 12.2 Authoring flow
- Admin creates draft (manual or AI-assisted)
- Editor checks facts + sources
- Approve → publish

### 12.3 SEO basics
- Clean URLs:
  - `/cv/tata/ace-gold/`
  - `/compare/tata-ace-vs-leyland-dost/`
- Schema.org:
  - Product, Article, FAQPage, BreadcrumbList

---

## 13) AI layer (safe + explainable)

### 13.1 AI features (MVP-safe)
- **Spec normalization**: convert messy fields into consistent format
- **Content draft generator**: create draft text from structured specs
- **Q&A (retrieval)**: answer based on your own DB + published content only
- **Missing-data detector**: highlight gaps in specs

### 13.2 “Human approval loop” (must-have)
AI never publishes directly.

```
AI generates draft -> Admin reviews -> Fix -> Approve -> Publish
```

### 13.3 RAG (retrieval augmented generation)
- Store published content + key specs in a “knowledge index”
- AI answers only using retrieved passages
- Show “Sources used” to the user

---

## 14) Security & compliance (minimum required)

- Passwords hashed (bcrypt/argon2)
- JWT secrets never in code, only in environment variables
- Rate limiting on auth endpoints
- Audit logs for admin changes
- Data disclaimer on pages (price/spec changes)
- No private user data exposed to public endpoints

---

## 15) Testing plan (what to test)

### 15.1 Backend tests
- Unit tests: validators, calculations (EMI/TCO)
- API tests: list models, variant detail, compare
- Auth tests: register/login/refresh/logout
- Admin tests: import, approve content

### 15.2 Frontend tests
- Page renders (home/search/model/variant/compare)
- Filter behavior on search
- Compare sticky header + missing-value handling
- Mobile responsiveness

### 15.3 Data tests
- Duplicate detection
- Spec range validation
- Search index parity checks

---

## 16) CI/CD pipelines (GitHub Actions)

### 16.1 PR checks (every pull request)
- Lint (frontend + backend)
- Unit tests
- Build check (Next.js build)
- API type check (mypy if used)

### 16.2 Main branch
- Build Docker images
- Push to registry
- Deploy to staging
- Run smoke tests

### 16.3 Production release
- Tag release
- Deploy with rollback strategy

---

## 17) Deployment (simple to advanced)

### 17.1 MVP deployment (fast)
- One VM (Hetzner/AWS Lightsail/DigitalOcean)
- docker-compose running:
  - web
  - api
  - postgres
  - redis
  - search
- Nginx reverse proxy + SSL (Let’s Encrypt)

### 17.2 Advanced deployment (later)
- Kubernetes cluster
- Managed Postgres
- Managed Redis
- CDN for images

---

## 18) Milestones (build order)

### Phase 0 — Setup (Week 1)
- Repo structure
- Docker infra
- Basic web + api running
- DB migrations

### Phase 1 — Core research (Week 2–4)
- Manufacturers/models/variants APIs
- Model + Variant pages
- Compare page
- Search index integration

### Phase 2 — Data import (Week 5–6)
- Import pipeline
- Validation scripts
- Reindex job
- Admin panel basic

### Phase 3 — Calculators + Content (Week 7–8)
- EMI/TCO/fuel calculators
- Content system (draft/publish)
- SEO foundations

### Phase 4 — AI assist (Week 9–10)
- Spec normalization
- AI draft generator + approval
- Q&A with sources

### Phase 5 — Launch hardening
- Monitoring + logs
- Security review
- Performance tuning

---

## 19) “Layman guide”: How to build a feature (template)

When adding ANY feature, follow this simple checklist:

1. **Define the user story**
   - “As a user, I want to compare 3 trucks so I can choose the best.”

2. **Decide what data is needed**
   - Which DB tables/fields?

3. **Add/Update DB**
   - Migration: create/change tables

4. **Add Backend API**
   - Create endpoint + validation + tests

5. **Update Search (if needed)**
   - Reindex job updates search fields

6. **Build Frontend UI**
   - Page + components + loading states + error states

7. **Test**
   - Unit + integration + manual checklist

8. **Deploy**
   - Staging first, then production

---

## 20) Glossary (simple meanings)

- **Frontend**: what users see (website UI)
- **Backend**: server that provides data to the frontend
- **Database**: where permanent data lives (truth)
- **API**: a “data doorway” the frontend uses to request data
- **Search index**: a fast “lookup engine” for searching/filtering
- **Cache**: temporary memory to speed up repeated requests
- **CI/CD**: automated testing + deployment pipelines
- **RAG**: AI answers using your own data instead of guessing

---

## 21) Next steps (what you should do now)

If you are in the **ideation stage** but want execution:

1. Lock the MVP scope:
   - Search → model → variant → compare → shortlist → calculators
2. Finalize the DB schema (tables + relationships)
3. Implement backend read APIs
4. Build core pages
5. Import 50–100 vehicles first (seed dataset)
6. Add AI draft generation after the core is stable

---

## Appendix A: MVP “Definition of Done”

A feature is “done” only if:
- Works on desktop + mobile
- Has loading + empty + error states
- Has basic tests
- Has sources/disclaimer where needed
- Does not break compare/search

---
