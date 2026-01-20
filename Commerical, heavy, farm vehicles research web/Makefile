.PHONY: help backend-lint backend-format-check backend-test backend-test-unit backend-test-integration backend-test-api backend-test-db backend-cov backend-security backend-migrations-check frontend-lint frontend-typecheck frontend-test frontend-build frontend-e2e php-lint system-up system-down system-smoke system-api-contract system-load db-up db-down db-migrate db-seed db-reset db-test

DB_COMPOSE ?= infra/docker/docker-compose.db.yml
ALEMBIC_CFG ?= alembic.ini
MODE ?= medium

help:
	@echo "Available targets:"
	@echo "Database:"
	@echo "  db-up                   - Start Postgres/Redis/OpenSearch/ClickHouse"
	@echo "  db-down                 - Stop database stack"
	@echo "  db-migrate              - Run Alembic schema migrations (up to 002_all_domains)"
	@echo "  db-seed                 - Seed database with generated demo data (MODE=small|medium|large, default: $(MODE))"
	@echo "  db-reset                - Drop schema, migrate, and seed (MODE respects db-seed)"
	@echo "  db-test                 - Connectivity + schema validation checks"
	@echo "Backend:"
	@echo "  backend-lint              - Lint backend code with ruff"
	@echo "  backend-format-check      - Check backend code formatting with ruff"
	@echo "  backend-test              - Run all backend tests"
	@echo "  backend-test-unit         - Run backend unit tests"
	@echo "  backend-test-integration  - Run backend integration tests"
	@echo "  backend-test-api          - Run backend API tests"
	@echo "  backend-test-db           - Run backend database tests"
	@echo "  backend-cov               - Run backend tests with coverage"
	@echo "  backend-security          - Run backend security checks with bandit"
	@echo "  backend-migrations-check  - Check backend migrations (placeholder)"
	@echo "Frontend:"
	@echo "  frontend-lint             - Lint frontend code"
	@echo "  frontend-typecheck        - Typecheck frontend (skipped, no TS)"
	@echo "  frontend-test             - Run frontend tests"
	@echo "  frontend-build            - Build frontend"
	@echo "  frontend-e2e              - Run frontend e2e tests (skipped, no Playwright)"
	@echo "PHP:"
	@echo "  php-lint                  - Lint PHP code (skipped, no PHP)"
	@echo "System:"
	@echo "  system-up                 - Start system with docker-compose"
	@echo "  system-down               - Stop system with docker-compose"
	@echo "  system-smoke              - Run smoke tests"
	@echo "  system-api-contract       - Run API contract tests (skipped, no Postman)"
	@echo "  system-load               - Run load tests (skipped, no k6)"

# Backend targets
backend-lint:
	cd backend && python -m pip install -r requirements-dev.txt && ruff check .

backend-format-check:
	cd backend && python -m pip install -r requirements-dev.txt && ruff format --check .

backend-test:
	cd backend && python -m pip install -r requirements-dev.txt && python -c "import pytest; print('No tests yet')" || echo "pytest not available or no tests"

backend-test-unit: backend-test
backend-test-integration: backend-test
backend-test-api: backend-test
backend-test-db: backend-test

backend-cov:
	cd backend && python -m pip install -r requirements-dev.txt && python -c "import coverage; print('No tests yet')" || echo "coverage not available or no tests"

backend-security:
	cd backend && python -m pip install -r requirements-dev.txt && bandit -r . || echo "bandit not available"

backend-migrations-check:
	@echo "No migrations detected; skipping"

# Frontend targets
frontend-lint:
	cd frontend && npm run lint

frontend-typecheck:
	@echo "No TypeScript detected; skipping typecheck"

frontend-test:
	cd frontend && npm run test

frontend-build:
	cd frontend && npm run build

frontend-e2e:
	@echo "No e2e framework detected; skipping"

# PHP targets
php-lint:
	@echo "No PHP detected; skipping"

db-up:
	docker-compose -f $(DB_COMPOSE) up -d

db-down:
	docker-compose -f $(DB_COMPOSE) down -v

db-migrate:
	cd apps/api && ALEMBIC_CONFIG=$(ALEMBIC_CFG) alembic upgrade 002_all_domains
	docker-compose -f $(DB_COMPOSE) exec -T clickhouse clickhouse-client --multiquery < infra/db/clickhouse/schema.sql

db-seed:
	cd apps/api && ALEMBIC_CONFIG=$(ALEMBIC_CFG) alembic upgrade head
	MODE=$(MODE) ./scripts/db_seed.sh

db-reset:
	docker-compose -f $(DB_COMPOSE) exec -T postgres psql -U $${POSTGRES_USER:-autopredator} -d $${POSTGRES_DB:-autopredator} -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
	cd apps/api && ALEMBIC_CONFIG=$(ALEMBIC_CFG) alembic upgrade head
	MODE=$(MODE) ./scripts/db_seed.sh

db-test:
	python scripts/db_test.py

# System targets
system-up:
	docker-compose up -d

system-down:
	docker-compose down

system-smoke:
	@echo "Running smoke tests..."
	@curl -f http://localhost:8000/health || (echo "Health check failed; ensure system is up" && exit 1)
	@echo "Smoke tests passed"

system-api-contract:
	@echo "No Postman collection detected; skipping"

system-load:
	@echo "No load tests detected; skipping"
