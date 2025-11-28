Here’s a ready-to-drop `TODO.md` for your project 👇

````markdown
# TODO – Autopredator Car Research Platform  
(Stack: HTML + CSS + JavaScript + PHP + MySQL/XAMPP)

Legend:  
- [ ] Not started  
- [~] In progress  
- [x] Done  

---

## 0️⃣ Project & Environment Setup

- [ ] Install & verify XAMPP (Apache + MySQL running)
- [ ] Create project folder: `C:\xampp\htdocs\autopredator`
- [ ] Copy / create base project structure:

  ```text
  autopredator/
  ├── index.php
  ├── brand.php
  ├── model.php
  ├── variant.php
  ├── compare.php
  ├── search.php
  ├── includes/
  │   ├── config.php
  │   ├── db.php
  │   ├── header.php
  │   ├── footer.php
  │   └── helpers.php
  ├── assets/
  │   ├── css/style.css
  │   ├── js/main.js
  │   └── images/
  ├── admin/
  │   ├── index.php
  │   └── ...
  └── docs/
      └── db-notes.md
````

* [x] Create `autopredator_unified` database in phpMyAdmin
* [x] Import SQL dump into `autopredator_unified`
* [x] Configure `includes/config.php` (PDO connection)
* [x] Create `test_db.php` for quick DB connection test

---

## 1️⃣ Core Backend (PHP + DB Layer)

### 1.1 DB Connection & Helpers

* [x] `includes/config.php` – central DB config (host, DB name, user, pass)
* [x] `includes/db.php` – reusable DB functions:

  * [x] `get_db()` returns PDO instance (singleton)
  * [x] Helper to run parameterised SELECT queries
  * [x] Helper to run INSERT/UPDATE/DELETE safely
* [x] `includes/helpers.php` – shared utility functions:

  * [x] Slug generator (for pretty URLs)
  * [x] Safe output / escaping (`e($string)`)

### 1.2 Core Entities (Queries & Functions)

Build PHP functions for reading from existing tables:

* [ ] Manufacturers

  * [ ] `get_all_manufacturers()`
  * [ ] `get_manufacturer_by_id($id)`
* [ ] Model families & models

  * [ ] `get_model_families_by_manufacturer($manufacturer_id)`
  * [ ] `get_models_by_family($family_id)`
  * [ ] `get_model_by_id($id)` (with generation info)
* [ ] Variants & specs

  * [ ] `get_variants_by_model($model_id)`
  * [ ] `get_variant_by_id($id)`
  * [ ] `get_specs_for_variant($variant_id)`
* [ ] Features

  * [ ] `get_features_for_variant($variant_id)`
  * [ ] Group features by category (Safety, Comfort, Tech, etc.)
* [ ] Prices

  * [ ] `get_prices_for_variant($variant_id, $city_id = null)`
* [ ] Search

  * [ ] `search_cars($filters)` (brand, body type, budget, fuel, transmission etc.)

---

## 2️⃣ Core Frontend (HTML + CSS + JS Layout)

### 2.1 Layout & Design

* [ ] `includes/header.php`

  * [ ] `<head>` meta tags, favicon, global CSS
  * [ ] Top navigation (Logo, Search bar, Menu)
* [ ] `includes/footer.php`

  * [ ] Footer links (About, Contact, Terms, Privacy)
* [ ] `assets/css/style.css`

  * [ ] Base typography, colors, spacing
  * [ ] Responsive grid for cards
  * [ ] Buttons, forms, tables, badges
* [ ] `assets/js/main.js`

  * [ ] Navbar interactions (mobile menu)
  * [ ] Simple front-end validation
  * [ ] Handle compare-selection, filter toggles

### 2.2 Core Pages

* [ ] `index.php` – Home

  * [ ] Search bar (by brand/model/keyword)
  * [ ] Quick filters (budget segments, body type)
  * [ ] Featured manufacturers or popular models
* [ ] `brand.php?manufacturer_id=`

  * [ ] Show brand info + logo
  * [ ] List all model families under this brand
* [ ] `model.php?model_id=`

  * [ ] Show model name, segment, generation, years
  * [ ] List variants (table/card)
* [ ] `variant.php?variant_id=`

  * [ ] Full variant spec page
  * [ ] Key specs summary at top (engine, power, mileage, transmission)
  * [ ] Detailed spec tabs (Specs / Features / Price / Photos)
* [ ] `compare.php?ids=1,2,...`

  * [ ] Side-by-side comparison for 2–4 variants
  * [ ] Highlight differences visually
* [ ] `search.php` – results page

  * [ ] Show filters + result cards
  * [ ] Paginate if many results

---

## 3️⃣ Search, Filters & Comparison Logic

### 3.1 Filters

* [ ] Backend filter parsing:

  * [ ] Budget (min–max price)
  * [ ] Body type
  * [ ] Fuel type
  * [ ] Transmission
  * [ ] Seating capacity
  * [ ] Brand
* [ ] Frontend UI for filters:

  * [ ] Sidebar filter (desktop)
  * [ ] Accordion filter (mobile)
  * [ ] “Clear filters” option

### 3.2 Comparison

* [ ] Allow user to “Add to Compare” from:

  * [ ] Model listing
  * [ ] Search results
  * [ ] Variant page
* [ ] Store compare list in:

  * [ ] JS (localStorage) + fallback to PHP session
* [ ] `compare.php`:

  * [ ] Fetch variants by IDs
  * [ ] Build spec matrix (rows = attributes, columns = cars)
  * [ ] Highlight differences with CSS

---

## 4️⃣ User Accounts & Favourites (Optional v1.5)

* [ ] DB tables for users and favourites:

  * [ ] `users` (id, name, email, password hash)
  * [ ] `user_favourites` (user_id, variant_id, created_at)
* [ ] Auth pages:

  * [ ] `login.php`
  * [ ] `register.php`
  * [ ] `logout.php`
* [ ] Basic session-based auth
* [ ] “Add to favourites” buttons on variant pages
* [ ] “My Garage” page listing user’s favourite cars

---

## 5️⃣ Admin Panel (Data Management)

Create a simple admin UI (under `/admin`) to view and edit data.

### 5.1 Admin Access

* [ ] `admin/login.php` (separate from user login)
* [ ] Admin session & middleware/check
* [ ] `admin/index.php` – admin dashboard overview

### 5.2 CRUD Screens (High-Level)

* [ ] Manufacturers

  * [ ] List manufacturers
  * [ ] Add / edit / deactivate manufacturer
* [ ] Model families & models

  * [ ] List models by brand
  * [ ] Add new model (family + generation)
  * [ ] Set generation years, fuel type defaults, etc.
* [ ] Variants

  * [ ] List variants per model
  * [ ] Add variant (name, engine, transmission, etc.)
* [ ] Specs & features

  * [ ] Assign specs to variant
  * [ ] Map features to variant via checkboxes
* [ ] Prices

  * [ ] Manage ex-showroom / on-road prices
  * [ ] City-wise price entries

### 5.3 Import / Bulk Actions

* [ ] Build “Import CSV” page for:

  * [ ] Manufacturers
  * [ ] Model families & models
  * [ ] Variants
* [ ] Simple status logs after upload (success, failed rows)

---

## 6️⃣ Strategic Database Population Plan

Goal: populate `autopredator_unified` with **complete, structured, realistic** data for the Indian market (new + discontinued, with generations & variants).

### 6.1 Schema Review & Cleanup

* [ ] Document all car-related tables in `docs/db-notes.md`:

  * [ ] `manufacturers`
  * [ ] `model_families`
  * [ ] `models`
  * [ ] `model_lifecycle`
  * [ ] `variants`
  * [ ] `vehicle_specs`
  * [ ] `features` + `variant_features`
  * [ ] `prices`
  * [ ] `images`
* [ ] Confirm primary keys, foreign keys, unique constraints
* [ ] Add missing indexes on common search fields:

  * [ ] manufacturer_id
  * [ ] model_family_id / model_id
  * [ ] body_type, fuel_type, price range

### 6.2 Base Manufacturer & Model List

* [ ] Finalise master list of manufacturers (India)
* [ ] Insert/verify manufacturers in `manufacturers`
* [ ] For each manufacturer:

  * [ ] Define `model_families` (Swift, Baleno, Creta, Nexon, etc.)
  * [ ] Insert into `model_families` with consistent naming
* [ ] Decide naming rules:

  * [ ] Separate entry per generation
  * [ ] Separate entry per major facelift (if needed)

### 6.3 Model Generations & Lifecycles

* [ ] For each model family:

  * [ ] Identify generations (years, code names)
  * [ ] Map to `models` and/or `model_lifecycle`
  * [ ] Insert `models` rows:

    * [ ] Generation start year
    * [ ] Generation end year (if discontinued)
    * [ ] Fuel types available
    * [ ] Body types (hatchback, sedan, SUV, etc.)

### 6.4 Variants & Specs

* [ ] Define variant naming template:

  * [ ] Example: “ZX MT Petrol”, “VXi CNG AMT”, etc.
* [ ] For each model generation:

  * [ ] List all variants (as close to real market as possible)
  * [ ] Insert into `variants`
* [ ] Specs:

  * [ ] Map engine, transmission, drivetrain, power, torque, mileage, dimensions
  * [ ] Insert rows into `vehicle_specs` referencing `variant_id`

### 6.5 Features & Feature Mapping

* [ ] Finalise feature master list:

  * [ ] Safety (Airbags, ABS, ESP, Hill Hold, etc.)
  * [ ] Comfort & convenience (Auto AC, Cruise Control, etc.)
  * [ ] Infotainment & connectivity
  * [ ] Exterior / lighting
* [ ] Insert all into `features` table (if not already)
* [ ] For each variant:

  * [ ] Map features in `variant_features` (variant_id, feature_id)
  * [ ] Consider bulk insert from CSV for speed

### 6.6 Prices & City Mapping

* [ ] Decide how many cities to support (Tier-1, 2, 3)
* [ ] Insert cities into `cities` table (if exists)
* [ ] For each variant:

  * [ ] Add `prices` rows (ex-showroom; approx on-road)
  * [ ] Use logic: base price + adjustments per city

### 6.7 Data Quality & Scripts

* [ ] Create `scripts/` (can be PHP or external language) for:

  * [ ] Checking missing specs per variant
  * [ ] Checking variants with no prices
  * [ ] Checking variants with inconsistent fuel/transmission
* [ ] Add “Data Quality Dashboard” in admin:

  * [ ] Counts of cars with missing images
  * [ ] Missing prices
  * [ ] Missing features

---

## 7️⃣ AI Agent – Data & Content Manager

Goal: build an **AI helper** that understands your schema and helps with:

* Suggesting **SQL INSERT/UPDATE** commands
* Filling missing specs/features
* Generating descriptions & blog content
* Assisting in long-term DB maintenance

### 7.1 Agent Scope & Design

* [ ] Define clear responsibilities:

  * [ ] Read-only query helper (what data is already in DB)
  * [ ] Data population assistant (proposes SQL for new models/variants)
  * [ ] Content writer (variant descriptions, comparisons, blog posts)
* [ ] Write a high-level design doc: `docs/ai-agent-design.md`

### 7.2 Tools / Integration Layer

* [ ] Create a small **backend script** (PHP or Python) which:

  * [ ] Can read DB schema (`SHOW TABLES`, `DESCRIBE table`)
  * [ ] Can run safe SELECT queries
  * [ ] Can log SQL suggestions from AI into a staging table, e.g.:

    * `ai_sql_suggestions` (id, sql_text, type, status, created_at, approved_by_admin)
* [ ] API endpoint(s) for the AI agent:

  * [ ] `/api/ai/schema` – returns schema info as JSON
  * [ ] `/api/ai/sample-data` – returns sample rows
  * [ ] `/api/ai/submit-sql` – allows agent to submit INSERT/UPDATE as text (not auto-run)

### 7.3 Prompt Library for the Agent

* [ ] Prompt template: “Add new car model”:

  * [ ] Input: manufacturer, model family, generation, Indian market years, specs
  * [ ] Output: SQL for `models`, `variants`, `vehicle_specs`, `variant_features`, `prices`
* [ ] Prompt template: “Fill missing specs/features”

  * [ ] Input: partial variant info + known market information
  * [ ] Output: suggested specs + SQL updates
* [ ] Prompt template: “Write human-readable description”

  * [ ] Input: specs & features of variant
  * [ ] Output: 1–2 paragraph description for UI
* [ ] Prompt template: “Comparison summary”

  * [ ] Input: 2–3 variants specs
  * [ ] Output: pros/cons and difference summary for user

### 7.4 Admin Workflow for AI Suggestions

* [ ] In admin panel, create **AI Suggestions** section:

  * [ ] List of `ai_sql_suggestions` pending review
  * [ ] Show suggested SQL in a `<textarea>`
  * [ ] “Approve & Run” button (executes SQL in DB)
  * [ ] “Reject” button (marks as rejected)
  * [ ] Log which admin approved which change
* [ ] Optionally: backup before applying bulk changes

### 7.5 AI for Blog & Content

* [ ] Add table `articles` (id, slug, title, body, tags, created_at)
* [ ] Backend:

  * [ ] `/admin/articles/create` – form to request AI-generated article:

    * Topic (e.g., “Best sub-4m SUVs under 10L in 2025”)
    * Target audience
  * [ ] Backend calls AI with car data + topic
  * [ ] AI returns draft article → show editable text in admin
* [ ] Frontend:

  * [ ] `blog.php` – list articles
  * [ ] `blog-article.php?slug=` – show article page

---

## 8️⃣ Performance, Security & Maintenance

* [ ] Add basic caching where useful (PHP arrays / file cache for master lists)
* [ ] Implement simple rate limiting for APIs (if exposed publicly)
* [ ] Sanitize all GET/POST parameters
* [ ] Escape all output to avoid XSS
* [ ] Create cron (or manual script) for:

  * [ ] Nightly DB backup (dump `autopredator_unified`)
  * [ ] Rebuilding any search indexes (if later added)

---

## 9️⃣ Launch Checklist (When Going Public)

* [ ] Switch from `root` user & empty password to secure DB user
* [ ] Move configuration secrets out of webroot
* [ ] Disable `test_db.php` and raw debug pages
* [ ] Enable HTTPS on production server
* [ ] Add basic Terms of Use & Privacy Policy pages
* [ ] Add SEBI/financial disclaimer if any price/finance suggestions are provided

---

```

If you want, next step I can:

- Turn any one section (for example **6. Strategic Database Population** or **7. AI Agent**) into a **step-by-step execution plan** with exact scripts, example SQL, and example AI prompts you’ll use in Deep Research / ChatGPT.
```
