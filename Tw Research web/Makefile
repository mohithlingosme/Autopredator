COMPOSE_CMD = docker compose --env-file infra/.env -f infra/docker-compose.yml
PYTHON ?= python
SEED_CONFIG ?= scripts/seed/seed_config.json

-include infra/.env
export $(shell sed -ne 's/^\([^#][^=]*\)=.*/\1/p' infra/.env 2>/dev/null)
DATABASE_URL ?= postgresql://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@$(POSTGRES_HOST):$(POSTGRES_PORT)/$(POSTGRES_DB)

.PHONY: infra-up infra-down db-migrate db-seed db-seed-medium db-seed-large db-reset-and-seed search-reindex smoke-test

infra-up:
	$(COMPOSE_CMD) up -d

infra-down:
	$(COMPOSE_CMD) down

db-migrate:
	docker run --rm --network=autopredator_data_net --env-file infra/.env \
		-e POSTGRES_HOST=postgres \
		-v "$(PWD)/infra/db/migrations:/flyway/sql" \
		-v "$(PWD)/infra/db/flyway.conf:/flyway/conf/flyway.conf" \
		flyway/flyway:9.22.3 -configFiles=/flyway/conf/flyway.conf migrate

db-seed: db-migrate
	DATABASE_URL="$(DATABASE_URL)" $(PYTHON) scripts/seed/seed_db.py --reset --small

db-seed-medium: db-migrate
	DATABASE_URL="$(DATABASE_URL)" $(PYTHON) scripts/seed/seed_db.py --reset --medium

db-seed-large: db-migrate
	DATABASE_URL="$(DATABASE_URL)" $(PYTHON) scripts/seed/seed_db.py --reset --large

db-reset-and-seed: db-migrate
	DATABASE_URL="$(DATABASE_URL)" $(PYTHON) scripts/seed/seed_db.py --reset --medium

search-reindex:
	$(PYTHON) scripts/search_reindex.py

smoke-test:
	$(PYTHON) scripts/smoke_test_data_layer.py
