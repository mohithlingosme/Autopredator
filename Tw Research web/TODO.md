# Local Environment Setup TODO

## A) Local prerequisites & pinned runtimes (P0)
- [x] Add Node version pin (.nvmrc already exists with Node 20)
- [x] Add Python version pin (.python-version already exists with 3.11)
- [x] Decide package manager: npm (configure workspaces in root package.json)
- [x] Update README.md with "Prerequisites" section (Git, Node, Python, Docker Desktop, VS Code; install instructions for npm; Windows notes)

## B) Cross-platform bootstrap + dev + check scripts (P0)
- [x] Create scripts/bootstrap (.sh and .ps1): installs deps across monorepo
- [x] Create scripts/dev (.sh and .ps1): starts local dependencies + API + Web concurrently
- [x] Create scripts/check (.sh and .ps1): runs format check + lint + typecheck + unit tests
- [x] Add root package.json with commands: dev, bootstrap, check, api:dev, api:test, web:dev, web:build

## C) Environment variables & secrets (P0)
- [x] Add .env.example at root
- [x] Add apps/web/.env.example
- [x] Add apps/api/.env.example
- [x] Document env naming conventions and required variables in docs/Local_environment.md
- [x] Add env validation: API (pydantic-settings), Web (zod schema)
- [x] Ensure .env files are gitignored

## D) Local database & dependencies via Docker Compose (P0)
- [x] Add docker-compose.yml: Postgres, Redis
- [x] Add infra/db init strategy: init.sql or migrations folder
- [x] Add scripts/db-up, scripts/db-down, scripts/db-reset (.sh and .ps1)
- [x] Document DB connection info in docs/Local_environment.md + .env.example

## E) Backend local run (API) (P0)
- [x] Ensure apps/api has reliable local run with hot reload (uvicorn --reload if FastAPI)
- [x] Add Makefile or scripts: api-install, api-dev, api-test, api-typecheck, api-lint, api-format, api-format-check
- [x] Ensure minimal pytest test passes
- [x] Add /healthz endpoint (and /readyz if DB required)
- [x] Ensure logging defaults (LOG_LEVEL env)

## F) Frontend local run (Web) (P0)
- [x] Ensure apps/web has dev/build/preview scripts
- [x] Add lint/format/typecheck scripts
- [x] Add local proxy config to avoid CORS (Vite proxy)
- [x] Document how to point web to local API (API base URL)

## G) Worker local run (P0)
- [x] Create apps/workers/ placeholder
- [x] Provide scripts/worker-dev (.sh and .ps1)
- [x] Define simple worker loop stub (Python)
- [x] Wire to Redis if needed
- [x] Document how to run worker locally

## H) Local auth & test users (P1)
- [x] Provide simple dev auth strategy (dev token / mock auth / bypass via env)
- [x] Provide sample test users + roles as fixtures or docs

## I) Developer experience (DX) standards (P1)
- [x] Add .vscode/extensions.json
- [x] Add .vscode/settings.json (format on save, ESLint, Python formatting, ruff)
- [x] Add .vscode/launch.json for debugging API
- [x] Add "Troubleshooting" section in docs/Local_environment.md (port conflicts, docker issues, migrations, env problems)

## J) Documentation (P0)
- [x] Create docs/Local_environment.md explaining prerequisites, bootstrap, run dev, run checks, db reset, common problems
- [x] Update README.md to link to docs/Local_environment.md

## Infrastructure Foundation (Local → Staging → Production)

### A) Infra strategy & environments (P0)
- [x] Define environments: local, dev, staging, production
- [x] Decide and document hosting strategy: VPS + Docker Compose (default)
- [x] Add env-specific notes: domains/subdomains plan, deployment triggers (dev branch → staging, tags → production)
- [x] Document tenancy impacts (single-org vs multi-org) only as infra considerations

### B) Containerization baseline (P0)
- [x] Add Dockerfiles: apps/web/Dockerfile, apps/api/Dockerfile, apps/workers/Dockerfile (even if placeholder)
- [x] Add .dockerignore per app
- [x] Add Compose stacks: docker-compose.yml (local dependencies only), infra/compose/docker-compose.staging.yml, infra/compose/docker-compose.prod.yml
- [x] Ensure compose uses named volumes and explicit networks

### C) Reverse proxy + routing + TLS (P0)
- [x] Choose reverse proxy: Traefik recommended (automatic TLS), OR Nginx (manual certbot)
- [x] Implement proxy config so: / routes to web, /api routes to api, health endpoints reachable
- [x] Add TLS with Let's Encrypt for staging/prod: auto renew strategy, HTTP → HTTPS redirect
- [x] Add basic security headers at proxy layer

### D) Networking & port exposure (P0)
- [x] Define internal ports for services
- [x] Ensure only proxy exposes 80/443 publicly
- [x] Create separate networks: public (proxy <-> services), private (db/redis/internal)
- [x] Ensure db/redis not exposed to host by default in staging/prod

### E) Database infrastructure (P0)
- [x] Pick database engine (Postgres default unless repo clearly uses MySQL)
- [x] Add backup strategy: infra/scripts/backup/backup_db.sh (+ optional .ps1 if needed), retention policy documented (e.g., 7/30/90 days), restore script + steps
- [x] Add migration policy: how migrations run on deploy (manual step or CI step), rollback strategy documented
- [x] Add DB health checks in compose

### F) Cache/queue infrastructure (P0/P1)
- [x] Add Redis service in local + staging/prod if workers expected
- [x] Document queue conventions (names, retries, DLQ approach)
- [x] Add worker scaling notes (replicas in compose, or multiple services)

### G) Secrets & configuration management (P0)
- [x] Add env templates: infra/env/.env.staging.example, infra/env/.env.prod.example
- [x] Document secrets approach: MVP: server-side env files with strict permissions, Phase 2: Docker secrets or Vault
- [x] Ensure all secret files are gitignored
- [x] Add secret scanning guidance (GitHub secret scanning or gitleaks notes)

### H) CI/CD deployment pipeline hooks (P0)
- [x] Add GitHub Actions workflow(s) to build/push images to GHCR: staging: on merge to dev, production: on tag (SemVer)
- [x] Add deploy step approach: SSH to server and run docker compose pull + up -d, or trigger a server-side deploy script
- [x] Add post-deploy smoke tests (curl /healthz, etc.)
- [x] Add rollback procedure (redeploy previous tag)

### I) Observability baseline (P1)
- [ ] Ensure API/workers log to stdout (structured JSON recommended)
- [ ] Add log rotation (docker logging driver options or host-level note)
- [ ] Provide optional stack: Grafana + Loki + Promtail in infra/compose/observability.yml (optional)
- [ ] Add basic uptime and error-rate monitoring plan in docs

### J) Security hardening baseline (P1)
- [ ] Add infra/runbooks/security_hardening.md: firewall rules (ufw), SSH hardening, fail2ban suggestion, rate limiting at proxy
- [ ] Ensure staging/prod configs are safer than local

### K) Infrastructure-as-Code structure (P1/P2)
- [ ] Create infra folder structure: infra/compose/, infra/proxy/ (traefik or nginx configs), infra/scripts/backup/, infra/runbooks/
- [ ] Add runbooks: deploy_staging.md, deploy_production.md, rollback.md, restore_backup.md, incident_response.md

### L) Cost, scaling, reliability notes (P1/P2)
- [ ] Document MVP sizing recommendations (CPU/RAM/Disk)
- [ ] Document scaling triggers and next steps (add replicas, upgrade DB, CDN)
- [ ] Document what "HA later" would look like
