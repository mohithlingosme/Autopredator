# Development_plan.md — Autopredator Fleet Manager (India)

> Goal of this document: **A complete “build-from-zero” guide**. If a non-technical person reads it, they should still understand **what to build, why, in what order, and how to run it**.
>
> **Assumptions (because you didn’t paste repo details):**
> - Web app + API + database.
> - India-first (INR, GST, Indian address formats, FASTag, state permits, RTO docs).
> - Recommended stack: **Frontend: Next.js**, **Backend: FastAPI**, **DB: PostgreSQL**, **Cache: Redis**, **Background jobs: Celery**, **Search: Meilisearch/Elastic (later)**, **Docker for local**.
> - If your repo uses different tech, keep the *plan* and swap commands/paths.

---

## 0) What this app is (simple explanation)

This is a **Fleet Management System** for companies that own/operate vehicles (commercial, heavy, construction, farm, etc.). It helps them:

- Register vehicles and documents
- Assign drivers
- Track trips and mileage (manual or GPS integration)
- Track fuel, expenses, maintenance
- Remind for insurance/PUC/fitness/permits
- Generate reports (cost per km, utilization, downtime)
- Provide admin controls (roles, approvals, audit logs)
- Add AI later (anomaly detection, predictive maintenance, smart insights)

---

## 1) What you will build (features in plain English)

### Core (MVP)
1. **Login & roles**
   - Admin / Manager / Operator / Driver / Accountant / Viewer
2. **Vehicles**
   - Add vehicle, type (truck, excavator, tractor…), make/model, registration, ownership, depot
3. **Drivers**
   - Driver profile, license details, availability, assignment history
4. **Trips**
   - Create trip, assign vehicle + driver, start/end, distance, route, load type
5. **Fuel logs**
   - Fuel fill entry (liters, price, station), link to vehicle + odometer
6. **Maintenance**
   - Service entry, parts, costs, downtime, next due
7. **Documents & compliance**
   - Insurance, permit, fitness, pollution (PUC), RC, FASTag info
   - Expiry reminders
8. **Dashboard**
   - Active vehicles, upcoming expiries, monthly costs, utilization

### After MVP (Phase 2+)
- Vendor management (workshops, fuel stations)
- Invoices + GST reports
- Tyre management
- Driver behavior scoring (if telematics)
- GPS/telematics integration
- AI insights

---

## 2) High-level architecture (how pieces connect)

### Components
- **Frontend (Web UI)**: users interact here
- **Backend (API)**: business rules + security
- **Database**: stores everything
- **Cache (Redis)**: faster reads + sessions + rate limit
- **Background worker**: sends reminders, generates reports, imports data
- **Object storage**: store documents (PDF/JPG)
- **Observability**: logs + metrics

### Simple flow
User → Frontend → API → Database  
Uploads → API → Object storage  
Reminders/Reports → Worker → SMS/Email/WhatsApp (later)

---

## 3) Repo structure (recommended)

If starting fresh:

fleetmanager/
apps/
web/ # Next.js frontend
api/ # FastAPI backend
packages/
shared/ # shared types, constants
infra/
docker/ # docker-compose, nginx, scripts
k8s/ # (later) Kubernetes manifests
docs/
.github/workflows/ # CI/CD
README.md
Development_plan.md

markdown
Copy code

If you already have a repo, adapt this naming.

---

## 4) Development rules (so the project doesn’t become messy)

### Golden rules
- Everything important is version-controlled (code, migrations, docs).
- No secrets in git. Use `.env`.
- Every DB change = migration.
- Every feature = tests + basic docs.
- Logs must be structured (JSON logs are best).

### Definition of Done (DoD)
A feature is “done” only if:
- UI works
- API works
- Validations done
- Permissions done
- Tests added
- Documentation updated
- CI passes

---

## 5) Local setup (step-by-step)

### Install these once
1. **Git**
2. **Node.js (LTS)**
3. **Python 3.11+**
4. **Docker Desktop**
5. **VS Code** (recommended)

### Clone project
```bash
git clone <your-repo-url>
cd fleetmanager
Environment files
Create:

apps/api/.env

apps/web/.env.local

Example (API):

env
Copy code
ENV=dev
DATABASE_URL=postgresql+psycopg://postgres:postgres@localhost:5432/fleetmanager
REDIS_URL=redis://localhost:6379/0
JWT_SECRET=change_me
UPLOAD_BUCKET=local
Example (Web):

env
Copy code
NEXT_PUBLIC_API_BASE_URL=http://localhost:8000
Run services (DB + Redis)
bash
Copy code
cd infra/docker
docker compose up -d
Run backend
bash
Copy code
cd apps/api
python -m venv .venv
# Windows: .venv\Scripts\activate
# Linux/Mac:
source .venv/bin/activate
pip install -r requirements.txt

# Apply migrations
alembic upgrade head

# Start API
uvicorn app.main:app --reload --port 8000
Run frontend
bash
Copy code
cd apps/web
npm install
npm run dev
You should now have:

Web: http://localhost:3000

API: http://localhost:8000/docs

6) Data model (what tables you need)
MVP tables (minimum)
users (id, name, email, phone, password_hash, role, status)

organizations (multi-company support)

depots (locations)

vehicles

drivers

trips

fuel_logs

maintenance_jobs

documents

alerts (expiry reminders)

audit_logs (who changed what)

Vehicle fields (India-ready)
registration_number (KA01AB1234)

vehicle_type (truck, tipper, excavator…)

manufacturer, model, year

chassis_no, engine_no

fuel_type (diesel/cng/electric)

odometer_current

insurance_expiry, permit_expiry, fitness_expiry, puc_expiry

fastag_id (optional)

ownership (owned/leased)

7) API design (how endpoints should look)
Auth
POST /auth/register (admin only)

POST /auth/login

POST /auth/logout

GET /auth/me

Vehicles
GET /vehicles

POST /vehicles

GET /vehicles/{id}

PATCH /vehicles/{id}

DELETE /vehicles/{id} (soft delete)

Drivers
GET /drivers

POST /drivers

PATCH /drivers/{id}

Trips
GET /trips

POST /trips

PATCH /trips/{id}/start

PATCH /trips/{id}/end

Fuel
GET /fuel-logs

POST /fuel-logs

Maintenance
GET /maintenance

POST /maintenance

PATCH /maintenance/{id}

Documents
POST /documents/upload

GET /documents

GET /documents/{id}

Reports (MVP)
GET /reports/cost-summary?month=YYYY-MM

GET /reports/vehicle-utilization?month=YYYY-MM

Design principle: Keep endpoints simple and consistent.

8) Frontend pages (what screens to build)
MVP pages
/login

/dashboard

/vehicles

/vehicles/new

/vehicles/[id]

/drivers

/trips

/fuel

/maintenance

/documents

/reports

/settings/users (admin)

UI components you will reuse
Table with filters + pagination

Modal (confirm delete)

Form builder (VehicleForm, DriverForm…)

Date picker (expiry)

File uploader (documents)

KPI cards (dashboard)

9) Permissions (role-based access)
Simple MVP permission map
Admin: everything

Manager: vehicles/drivers/trips/reports

Operator: create/update trips, fuel, maintenance

Accountant: fuel + maintenance + reports

Driver: view assigned trip, submit trip updates (optional)

Viewer: read-only

Implementation: backend enforces permissions, frontend only hides UI.

10) Validation rules (so data stays clean)
Examples:

Registration number format check (basic)

Odometer cannot go backwards

Trip end date cannot be before start date

Fuel liters > 0, price >= 0

Expiry dates must be valid dates

Driver license expiry must be tracked

11) Background jobs (automation)
MVP jobs
Expiry reminder generator (daily)

Create alerts for insurance/permit/fitness/PUC expiring in next 30 days

Report snapshot (monthly)

Save monthly totals per vehicle for fast dashboards

Later:

Predictive maintenance

Abnormal fuel detection

12) AI features (later, but plan now)
AI v1 (safe + easy)
Fuel anomaly detection (sudden drop in mileage)

Maintenance due prediction (based on history)

Auto-summarize monthly report in simple language

What AI needs (data)
Trip distance + fuel liters + odometer

Maintenance entries + downtime

Vehicle category/type usage patterns

Rule: AI should recommend, not auto-edit data.

13) Testing plan (what to test)
Backend tests
Auth: login, token, role checks

Vehicles: create/update/list validation

Trips: lifecycle start/end rules

Fuel: odometer + cost rules

Maintenance: next due rules

Documents: upload + permissions

Frontend tests
Login flow

CRUD basic flows (vehicles/drivers)

Trip creation + completion

Error states (missing fields)

Permissions UI

Minimum test stack
Backend: pytest

Frontend: playwright (E2E) + vitest (unit)

14) CI/CD (automated checks)
GitHub Actions (recommended)
lint_api.yml (ruff/black)

test_api.yml (pytest)

lint_web.yml (eslint)

test_web.yml (unit)

e2e.yml (Playwright)

build_deploy.yml (staging/prod)

Branch rules
main = production

develop = staging

feature branches → PR → checks → merge

15) Deployment plan (simple & reliable)
Environments
Dev: your laptop

Staging: cheap server (testing)

Prod: stable server

Recommended hosting (India-friendly)
Any VPS + Docker (fastest)

Use:

Nginx reverse proxy

HTTPS (Let’s Encrypt)

Daily DB backups

Central logs

Production checklist
HTTPS enabled

Database backups tested

Secrets stored securely

Rate limiting enabled

Monitoring alerts configured

16) Security & compliance basics (India context)
Store passwords hashed (bcrypt/argon2)

Audit logs for edits

Document access restricted by org + role

Data retention policy (basic)

If you integrate GPS/driver behavior: add consent + privacy policy

17) Milestone roadmap (from scratch to advanced)
Phase 0 — Foundation (Week 1)
Repo structure

Docker compose (db, redis)

Backend skeleton + health route

Frontend skeleton + login page

CI basic lint/tests

Phase 1 — MVP Core (Weeks 2–4)
Auth + roles

Vehicles CRUD

Drivers CRUD

Trips CRUD + start/end

Fuel logs

Maintenance

Documents upload

Dashboard + basic reports

Phase 2 — Operations (Weeks 5–6)
Expiry reminders (jobs)

Audit logs

Better reporting + exports (CSV)

Phase 3 — Integrations (Weeks 7–10)
SMS/WhatsApp notifications

GPS/Telematics connector (optional)

Vendor management

Phase 4 — AI Layer (Weeks 11+)
Anomaly detection

Predictive maintenance

Smart summaries

18) Task breakdown (what to do in what order)
Step A: Build the base
 Setup DB schema + migrations

 Setup auth

 Setup layout + navigation

 Add role guard

Step B: Add core modules
 Vehicles module

 Drivers module

 Trips module

 Fuel module

 Maintenance module

 Documents module

Step C: Add reporting
 Monthly totals

 Cost per vehicle

 Utilization

Step D: Automation
 Expiry alerts job

 Notification channel (email first)

19) “How to add a new feature” (simple cookbook)
Example: “Add Tyre Management”

Add DB table: tyres, vehicle_tyres

Create API endpoints: list/create/update

Add UI pages: /tyres, /vehicles/[id]/tyres

Add validations (km, install date)

Add tests (API + UI)

Update docs + DoD checklist

20) Troubleshooting (common issues)
API can’t connect to DB
Is Docker running?

Is DATABASE_URL correct?

Did you run migrations?

Frontend shows “API not reachable”
Is API running on port 8000?

Is NEXT_PUBLIC_API_BASE_URL correct?

Login works but data is empty
Seed admin + sample vehicles

Confirm organization scoping

21) Seed data (so you can demo fast)
Create a seed.py that inserts:

1 org

1 admin user

5 vehicles

5 drivers

10 trips

10 fuel logs

5 maintenance entries

22) What to document as you build (mandatory)
Keep these updated:

README.md (how to run)

docs/API.md (routes + examples)

docs/DB.md (tables + relations)

docs/DEPLOYMENT.md (staging/prod steps)

23) Final output expectation (what “completed MVP” looks like)
A user can:

Login

Add vehicles & drivers

Create and complete trips

Log fuel and maintenance

Upload documents

See dashboard + basic monthly reports

Get expiry reminders

24) Next step (immediate action list)
If you want the fastest execution:

Create DB schema + migrations

Implement Auth + RBAC

Implement Vehicles CRUD (API + UI)

Implement Trips lifecycle

Implement Fuel + Maintenance

Implement Documents + reminders

Add reports + exports

Add CI pipelines

