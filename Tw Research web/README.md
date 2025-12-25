Autopredator — Motorcycle & Scooter Research Web

A dedicated two-wheeler research + comparison module inside the larger Autopredator ecosystem. This product helps users discover, evaluate, compare, and decide between motorcycles and scooters (including EV scooters) using structured specs, decision tools, and an AI layer for recommendations, pricing insights, review sentiment, and ownership-cost estimation. 

autopredator

1) What is the product?

A SEO-first research website + decision platform for:

Motorcycles (commuter, sport, cruiser, adventure, etc.)

Scooters (family, commuter, performance scooters)

EV scooters (range/charging/battery health focus)

Core promise: “Choose the right 2-wheeler faster, with cleaner UI + deeper, structured data + AI decision support.” 

autopredator

2) Features (full list)
A) Research & discovery (MVP)

Brand directory + brand pages

Model listing with faceted filters (price, mileage/range, engine cc, ABS, weight, seat height, charging time, etc.)

Model page + variant page with structured specs

Image gallery + color variants

“Similar alternatives” & “best in segment” suggestions (internal linking)

B) Compare & decide (MVP)

Compare 2–4 vehicles (differences-only toggle)

Shortlist / recently viewed

Personalized comparison insights (AI-assisted) 

autopredator

Feature prioritization tool (helps users pick what matters within budget) 

autopredator

C) Ownership & cost tools (MVP → v2)

Total Cost of Ownership (TCO) estimator: fuel/electricity, insurance, maintenance, depreciation 

autopredator

Fuel efficiency predictor (later: personalized by usage/behavior) 

autopredator

Resale value predictor 

autopredator

D) Reviews & trust (MVP)

Expert + user review aggregation

Sentiment analysis summary (pros/cons from reviews) 

autopredator

E) Price & availability (v2)

Intelligent pricing predictor (“best time to buy” using price trends) 

autopredator

Vehicle availability locator (dealer inventory pattern insights) 

autopredator

F) EV-focused tools (v2)

Charging station locator + range prediction/battery tools 

autopredator

Battery health monitoring + range prediction tools 

autopredator

G) Marketplace hooks (later)

Expand marketplace categories to include motorcycle specialty items 

autopredator

3) Sitemap & information architecture (SEO-first)
Primary navigation

/bikes

/scooters

/electric-scooters

/brands

/compare

/guides (content hub)

/tools (TCO, recommend, etc.)

Programmatic SEO collections

/best-bikes-under-100000

/best-scooters-for-city-commute

/best-electric-scooters-by-range

/bikes-with-dual-channel-abs

Entity pages

/brands/{brand}

/{type}/{brand}/{model}
Examples: /bikes/honda/cb350 | /scooters/tvs/ntorq

/{type}/{brand}/{model}/{variant}

Utility pages

/compare?ids=...

/recommend (quiz)

/tools/tco?vehicle_id=...

4) All possible user journeys
Journey 1 — “Find the best under budget”

Land on “Best scooters under ₹1.2L”

Apply filters (ABS, mileage, weight, storage)

Open 2–3 model pages

Add 2–4 variants to compare

Pick winner using “differences-only + verdict + TCO” 

autopredator

Journey 2 — “Compare two specific vehicles”

Search model A → open variant

Search model B → open variant

Compare → see spec deltas + AI insights (maintenance/resale/performance) 

autopredator

Journey 3 — EV scooter buyer

Filter EV scooters by range + charge time

Compare 3 EV options

View range prediction + charging locator (v2) 

autopredator

Decide using TCO and warranty/battery section 

autopredator

Journey 4 — “I don’t know what to buy” (Recommendation flow)

Take quiz: budget, usage, distance/day, road type, pillion, height

Get ranked list + explanations (why it fits)

Compare top 3 and pick 

autopredator

Journey 5 — Research-driven buyer (content → conversion)

Read guide “ABS vs CBS”

Click recommended bikes list

Compare and shortlist

(Later) go to dealer availability locator 

autopredator

5) Page blueprints (what each page contains)
A) Listing page (Bikes/Scooters/EV)

Filters (sticky on desktop, drawer on mobile)

Sort (price low→high, best mileage/range, most popular)

Cards: price, key specs, highlights, compare checkbox

SEO blocks: FAQs + internal links to “best under X” pages

B) Brand page

Brand overview

Top models + categories

Price buckets

Latest updates/guides

C) Model page

Hero: name, price range, key highlights

“Best for” tags (commute / comfort / performance / EV)

Key specs grid

Variant table (with price + key differences)

Pros/cons + quick verdict

Reviews summary + sentiment highlights 

autopredator

Similar alternatives

D) Variant page (conversion-heavy)

Exact variant pricing + key differentiators

Full spec table (structured)

Feature checklist + safety section (ABS, braking, tyres) 

autopredator

Ownership section (TCO, mileage)

Add to compare / shortlist

E) Compare page

Sticky compare header

Category sections: performance, comfort, features, cost

“Differences only” toggle

AI comparison summary (maintenance/resale/performance insight) 

autopredator

F) Tools pages

Recommendation quiz 

autopredator

TCO estimator 

autopredator

Price trend + “best time to buy” (v2) 

autopredator

6) Data blueprint + collection strategy
Core entities

Manufacturer

Model (type: bike/scooter/ev)

Variant

Specs (per variant)

Features + mapping

Prices (ex-showroom, on-road later; history for trend)

Media (images, colors)

Reviews (expert + user, plus AI sentiment outputs) 

autopredator

Two-wheeler spec fields (examples)

Bikes: engine_cc, power, torque, gearbox, kerb_weight, seat_height, brakes, ABS type, tyres, suspension, fuel_tank, mileage
Scooters: storage, seat_height, kerb_weight, wheel_size, braking, mileage
EV scooters: battery_kwh, range, motor_kw, top_speed, charge_time, charger_type, battery_warranty

Collection strategy (practical approach)

Seed MVP dataset (top brands + top models): curated JSON/CSV → validated import

Source hierarchy (for trust):

OEM brochures/spec sheets

Verified automotive portals/reviews for cross-check

Community feedback (flagged as “user reported”)

Change tracking

Store “data_source”, “last_verified”, “confidence_score”

Price history

Capture periodic snapshots (weekly/monthly) for trend predictor 

autopredator

7) Backend + APIs + Frontend plan

[ASSUMPTION] This module is built as a monorepo with a modern web frontend + API backend. (If you’re keeping PHP for now, map these endpoints to PHP controllers and keep the same API contract.)

Backend responsibilities

Entity APIs (brands/models/variants)

Search + filtering + facets

Compare API (2–4 vehicles)

Tools APIs (recommendation, TCO, price trend)

Caching for hot pages

Admin import pipeline (seed + updates)

API surface (MVP)

GET /api/brands

GET /api/models?type=&brand=&filters=...

GET /api/models/{modelSlug}

GET /api/variants/{variantSlug}

GET /api/compare?ids=a,b,c

POST /api/recommend (quiz → ranked list) 

autopredator

GET /api/tco?variant_id=... 

autopredator

Frontend responsibilities

SEO rendering (server-render or static generation for entity pages)

Clean filters UI + fast navigation

Compare UI

Structured data (schema.org: Product, FAQ, Breadcrumb)

8) AI features (included + roadmap + how we build them)
Included AI features from the Autopredator plan

AI vehicle recommendation engine 

autopredator

Personalized comparison insights 

autopredator

Intelligent pricing predictor (price trends → best time) 

autopredator

Fuel efficiency predictor 

autopredator

Safety feature comparison 

autopredator

TCO estimator 

autopredator

Review sentiment analysis 

autopredator

Resale value predictor 

autopredator

Feature prioritization tool 

autopredator

Availability locator 

autopredator

How we implement (phased, realistic)

Phase A (rules + heuristics, ship fast)

Recommendation: scoring model based on filters + weights

TCO: formula-based with configurable assumptions

Compare insights: deterministic “diff-to-text” generator

Phase B (ML/LLM-assisted, better quality)

Review sentiment: classify + summarize pros/cons 

autopredator

Pricing predictor: time-series over price_history 

autopredator

Resale prediction: regression model using age/brand/segment/market signals 

autopredator

Phase C (platform expansion)

Forecast demand for new vehicle categories like two-wheelers (for expansion planning) 

autopredator

EV tools: range predictions + charging locator 

autopredator

Additional possible AI (optional)

Multilingual localization AI for regional markets 

autopredator

Chatbot support for FAQs + buying help 

autopredator

9) USP (Unique Selling Proposition)

All-in-one approach with decision tools + AI personalization, built to match India’s needs (including EV support). 

autopredator


For the two-wheeler module specifically:

“Best UI + fastest site”

“Structured variant-level data”

“Compare + TCO + recommendations”

“Review sentiment + resale + price timing” 

autopredator

10) Proposed file structure

[ASSUMPTION] Monorepo layout (recommended for scaling across Autopredator modules).

motorcycle-research-web/
  README.md

  apps/
    web/                      # Frontend (Next.js/React or your current UI app)
      src/
        pages/                # routes: /bikes, /scooters, /brands/[brand] ...
        components/           # UI components (cards, filters, compare table)
        features/             # recommend, tco, compare
        styles/
        lib/                  # api client, helpers
    api/                      # Backend (FastAPI/Node/PHP controllers)
      src/
        routes/               # brands, models, variants, compare, recommend, tco
        services/             # business logic
        models/               # ORM models
        schemas/              # request/response validation
        ai/                   # recommender, sentiment, predictors
        db/
          migrations/
          seeds/

  packages/
    ui/                       # shared UI kit (buttons, cards, tables)
    shared/                   # types, constants, utilities

  data/
    seed/
      manufacturers.csv
      models.csv
      variants.csv
      specs.csv
      features.csv

  scripts/
    import_seed.py            # load CSV/JSON into DB
    validate_data.py          # schema validation + sanity checks

  docs/
    sitemap.md
    api_contract.md
    data_dictionary.md

## CI/CD and automation

This repo includes GitHub Actions workflows for CI (`.github/workflows/ci.yml`), security scanning (`.github/workflows/security.yml`), Docker image builds (`.github/workflows/docker.yml`), and deployment (`.github/workflows/deploy.yml`). See `docs/CI_CD.md` for details on what each workflow does, required secrets, and how to use the published GHCR images in `docker-compose.prod.yml`.
