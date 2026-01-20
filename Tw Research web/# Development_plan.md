# Development_plan.md
## Autopredator (India-only) — Vehicle Research + Content System (Layman-Friendly Build Guide)

> Goal of this document: If someone reads only this file, they should be able to **set up**, **build**, **test**, and **deploy** the app step-by-step — even if they are not an expert.

---

## 0) What you’re building (in simple words)

You are building a **research website/app** for **commercial vehicles, heavy vehicles, construction equipment, and farm vehicles** in India.

Users should be able to:
- Search vehicles/equipment (brand → model → variant)
- View specs, features, prices, running cost estimates
- Compare multiple models/variants
- Shortlist and share pages
- See trusted data + sources
- Use calculators (EMI, TCO, mileage, resale, load capacity etc.)
- Get AI help: “Which one should I buy?” / “Explain differences” / “Best for my use case”
- A “content system” creates and manages pages/articles/spec summaries at scale (human + AI workflow)

---

## 1) Non-negotiable rules (project constraints)

- **Geography:** India only (data, pricing, language, regulations)
- **Ownership:** Run by Indians / India-focused
- **Stage:** Ideation → MVP → Scale
- **Data must be trustworthy:** store source links + timestamps, allow manual approval

---

## 2) Suggested tech approach (simple + scalable)

This plan uses a modern “common” stack that’s easier to hire for and maintain.

### 2.1 Architecture overview
- **Frontend (Website UI):** Next.js (React)  
- **Backend (APIs):** FastAPI (Python)  
- **Database:** PostgreSQL  
- **Search:** PostgreSQL full-text initially → later Elasticsearch/OpenSearch if needed  
- **Cache:** Redis  
- **File storage:** S3-compatible (AWS S3 / DigitalOcean Spaces / MinIO)  
- **Background jobs:** Celery/RQ (Python)  
- **AI layer:** OpenAI/LLM + embeddings + RAG + human approval loop  
- **Deployment:** Docker + Nginx + VPS/Kubernetes (later)

### 2.2 Why this combination?
- Easy to build MVP fast
- Python = better for AI + data pipelines
- Next.js = SEO-friendly for research pages
- PostgreSQL is reliable for structured data

---

## 3) Roles (who does what)

Even if 1 person builds it, these are the “hats” they wear:

1. **Product Owner**: defines features, priorities
2. **UI/UX**: page designs, user journeys
3. **Frontend Dev**: Next.js pages and UI
4. **Backend Dev**: APIs, auth, database
5. **Data Engineer**: scraping, cleaning, ingestion pipelines
6. **QA**: testing + bug tracking
7. **DevOps**: deployment, monitoring
8. **Content Ops**: articles, approvals, data verification
9. **AI Engineer**: RAG, prompts, evaluation

---

## 4) Repo structure (recommended)

Single monorepo:

autopredator/
apps/
web/ # Next.js frontend
api/ # FastAPI backend
workers/ # background jobs (Celery/RQ)
packages/
ui/ # shared UI components (optional)
shared/ # shared types, helpers
infra/
docker/ # docker configs
nginx/ # reverse proxy configs
terraform/ # later (optional)
docs/
Development_plan.md
API.md
Data_model.md
Content_system.md
scripts/
seed/
importers/
maintenance/
.github/
workflows/ # CI/CD
docker-compose.yml
README.md

yaml
Copy code

---

## 5) Local setup (step-by-step)

### 5.1 Install essentials
- Git
- Node.js (LTS)
- Python 3.11+
- Docker Desktop (recommended)
- VS Code

### 5.2 Run everything locally using Docker
Create `docker-compose.yml` with:
- Postgres
- Redis
- API service
- Web service

Then run:
```bash
docker compose up --build
5.3 Environment variables (very important)
Create:

apps/api/.env

apps/web/.env.local

Examples:

DATABASE_URL=postgresql://...

REDIS_URL=redis://...

JWT_SECRET=...

S3_BUCKET=...

OPENAI_API_KEY=...

6) Database design (plain English)
You’ll store:

Vehicle entities (brand, model, variant)

Specs (engine, power, torque, payload, dimensions, tyre, axle config, etc.)

Features (AC, power steering, safety, telematics, etc.)

Pricing (ex-showroom / region, historical)

Content (articles, buying guides, comparisons)

Sources (links, brochures, manufacturer pages)

Users (accounts, shortlist, comparisons)

AI outputs (recommendations, summaries) with approval status

6.1 Core tables (MVP)
manufacturers

categories (truck, tractor, excavator, etc.)

models

variants

variant_specs

features

variant_features

price_history

regions (state/city)

content_pages

content_revisions

sources

users

shortlist

comparisons

ai_jobs

ai_outputs

Important: Every spec/price should reference a source and timestamp.

7) Backend (FastAPI) — what to build
7.1 API modules (MVP)
Auth

register/login/logout

JWT tokens

role-based access: user, editor, admin

Catalog

manufacturers/models/variants CRUD (admin)

browse + search endpoints (public)

Specs & Features

get specs by variant

feature list and tags

Pricing

price history by region/date

Compare

compare 2–5 variants

Shortlist

add/remove saved items

Content

pages (guides, explainers, review-like structured pages)

revisions + approval

AI

“recommendation” endpoint

“summary” endpoint

“content draft generation” job

7.2 API rules (simple rules)
Validate input always

Return consistent JSON shape

Pagination for list endpoints

Rate-limit public endpoints

Log all errors

8) Frontend (Next.js) — pages to build
8.1 Sitemap (MVP)
/ Home

/search Search + filters

/brands/[brand]

/models/[model]

/variants/[variant]

/compare?ids=...

/shortlist

/calculators

/calculators/emi

/guides

/guides/[slug]

/admin (protected)

/admin/catalog

/admin/content

/admin/sources

8.2 “What each page must contain”
Variant page

Title + category + hero key stats

Specs table (grouped)

Features checklist

Price (region-based)

Similar alternatives

Compare CTA + shortlist CTA

Source references

FAQ

SEO schema

Compare page

Sticky header

Highlight “best value”

Handle missing data gracefully

Shareable URL

9) Content System (very important)
This is how you scale pages, guides, and data-driven content.

9.1 Content types
Data-driven pages: model/variant pages generated from DB

Guides: “Best trucks under 20L”, “Best tractor for 5-acre farm”

Explainers: “What is payload vs GVW”

Comparison articles: “X vs Y”

News/Updates (optional)

9.2 Content workflow (human + AI)
Topic created (manual)

AI drafts content (structured template)

Editor verifies facts (checks sources)

Approve & publish

Monitor performance (SEO + feedback)

Update cycle (monthly/quarterly)

9.3 Templates (use these always)
Every guide page should have:

Summary (5–8 lines)

Best use cases

Top picks table

Detailed sections

Pros/cons

FAQ

Sources

9.4 Content database tables (minimum)
content_pages (id, type, slug, title, status, seo_meta, created_by)

content_revisions (page_id, version, body_md, generated_by_ai, approved_by, approved_at)

sources (id, url, title, publisher, fetched_at, reliability_score)

content_sources (page_id, source_id, note)

10) AI layer (simple and safe)
10.1 What AI should do (MVP)
Summarize specs into plain language

Recommend vehicles based on user needs:

payload, route type, terrain, budget, fuel preference

Draft content pages (not auto-publish)

Extract specs from brochures (semi-automated)

10.2 Guardrails
AI outputs must be labeled: “AI-generated draft”

Never store hallucinated facts as truth

Always attach citations (sources)

Add disclaimer: “Verify with dealer/manufacturer”

10.3 AI architecture (easy mode)
Store vehicle data in DB

Create embeddings for:

guides

spec explainers

FAQs

Use RAG: answer from your data + guides

11) Calculators (MVP list)
EMI calculator

Total cost of ownership (TCO)

Fuel cost estimator

Mileage-based monthly spend

Payload utilization calculator

Break-even calculator (loan vs cash)

Resale value estimator (rough range)

Maintenance schedule estimator

Each calculator needs:

Inputs

Output breakdown

Notes/assumptions

Shareable result link

12) Data collection strategy (how you get data)
12.1 Sources (India)
Manufacturer websites

Official brochures PDFs

Government portals (where applicable)

Trusted industry publications

Dealer price sheets (with disclaimers)

12.2 Data pipeline steps
Collect source

Extract structured data

Validate (rules + human spot-check)

Insert into DB

Tag with source + date

Publish pages

12.3 Validation rules examples
engine_cc must be numeric and within reasonable ranges

payload must not exceed GVW logic

price must be positive and region-labeled

13) Testing (so it doesn’t break)
13.1 Backend tests
Unit tests: services, validators

API tests: endpoints (happy + error cases)

Security tests: auth, rate-limits

13.2 Frontend tests
Component tests

Page rendering tests

SEO checks (meta tags present)

13.3 Data tests
Schema constraints

Missing source checks

Duplicate variant checks

14) CI/CD (automatic checks on every push)
14.1 Minimum pipelines
Lint backend

Test backend

Lint frontend

Test frontend

Build docker images

Deploy to staging (optional)

Deploy to production (manual approval)

15) Deployment (simple production path)
Option A (fastest): VPS + Docker
Nginx reverse proxy

API + Web containers

Postgres managed or on VPS

Redis container

Daily backups

Option B (scale): Kubernetes (later)
16) Monitoring (keep it healthy)
API logs (structured)

Error tracking (Sentry)

Uptime checks

Database backups + restore testing

Performance metrics (latency, cache hit rate)

17) MVP milestone plan (clear order)
Milestone 1: Foundation (Week 1–2)
Repo structure

Docker compose

DB schema v1

Auth basic

Milestone 2: Catalog + Pages (Week 2–4)
Manufacturers/models/variants

Variant page (basic)

Search + filters

Compare v1

Milestone 3: Content system (Week 4–6)
Content pages + revisions

Admin content panel

Sources linking

Publish flow

Milestone 4: Calculators + Shortlist (Week 6–8)
Shortlist + compare share links

3–5 calculators

Milestone 5: AI assistant (Week 8–10)
AI recommendation endpoint

AI summaries (with citations)

AI draft generator (admin-only)

18) Admin panel (minimum features)
Add/edit manufacturers/models/variants

Upload brochures + attach to variants

Manage sources + reliability score

Review AI drafts

Approve/publish content revisions

View basic analytics (top pages, searches)

19) Security basics (do not skip)
Strong JWT secret

Password hashing (bcrypt/argon2)

Rate limits for public endpoints

Input validation everywhere

Separate admin routes

Database least privilege user

20) “If you are a layman” — exact build order checklist
Follow this order:

Install Node, Python, Docker

Clone repo

Run docker compose

Confirm API health endpoint works

Create DB tables (migration)

Seed 5 manufacturers + 20 models + 50 variants

Build frontend pages:

home, search, variant

Build compare + shortlist

Add content system:

guides list + guide page

Add admin panel (basic CRUD)

Add calculators

Add AI (admin-only first)

Add tests + CI

Deploy to VPS

21) Definition of Done (how you know MVP is complete)
MVP is “done” when:

Search works

Variant pages show reliable specs and sources

Compare works for 2–5 variants

Shortlist works

At least 10 guides published via content system

At least 3 calculators working

Admin can add/edit catalog + content

AI can summarize/recommend with citations and approval workflow

Basic tests + CI running

Production deployment stable + backups enabled

22) Next steps (what you should do immediately)
Create repo structure exactly as above

Create DB schema v1 tables

Build Variant page first (it is the core)

Build Search + Compare

Build Content workflow

Then add AI + calculators

23) Appendix: Minimum “documentation files” you must maintain
README.md (how to run)

docs/API.md (all endpoints)

docs/Data_model.md (tables & fields)

docs/Content_system.md (workflow & templates)

docs/QA.md (testing plan)

docs/Deployment.md (how to deploy)