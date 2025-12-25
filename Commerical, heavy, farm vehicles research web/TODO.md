# Test Script Catalog Implementation TODO

## Backend (Python/FastAPI)
- [x] Add dev dependencies: ruff, pytest, bandit to backend/requirements-dev.txt
- [x] Create backend/pyproject.toml with ruff config
- [x] Create backend/pytest.ini with markers: unit, integration, api, db
- [x] Implement Makefile targets: backend-lint, backend-format-check, backend-test (placeholders), backend-cov, backend-security

## Frontend (React/npm)
- [x] Implement Makefile targets: frontend-lint, frontend-test (placeholder), frontend-build
- [x] Skip frontend-typecheck (no TS)
- [x] Skip frontend-e2e (no Playwright, optional)

## System (Root)
- [x] Create docker-compose.yml for dev
- [x] Implement Makefile targets: system-up, system-down, system-smoke

## Documentation
- [x] Update README.md with Testing section

## Notes
- Use placeholders for missing tests that skip gracefully
- Ensure scripts work in CI (Linux)
