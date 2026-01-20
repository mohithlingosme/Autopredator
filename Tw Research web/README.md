# Autopredator Monorepo

A monorepo for the Autopredator platform, containing multiple applications and shared packages.

## Project Structure

- `apps/web` - TypeScript/React frontend application
- `apps/api` - Python backend API
- `apps/workers` - Background workers (Python or Node)
- `packages/shared` - Shared libraries, types, and utilities
- `infra/` - Infrastructure as code
- `docs/` - Documentation
- `scripts/` - Utility scripts
- `tests/` - Cross-repo tests

## Getting Started

### Prerequisites

- **Git** - Version control system
- **Node.js** (see .nvmrc for version) - JavaScript runtime
- **Python** (see .python-version for version) - Python runtime
- **Docker Desktop** (recommended) - For local database and dependencies
- **VS Code** (recommended) - IDE with extensions for development

#### One-time Install Instructions

1. **Node.js and npm**: Download from [nodejs.org](https://nodejs.org/) or use nvm:
   ```bash
   nvm install 20
   nvm use 20
   ```

2. **Python**: Download from [python.org](https://python.org/) or use pyenv:
   ```bash
   pyenv install 3.11
   pyenv global 3.11
   ```

3. **Docker Desktop**: Download from [docker.com](https://docker.com/products/docker-desktop)

4. **VS Code**: Download from [code.visualstudio.com](https://code.visualstudio.com/)

#### Windows Notes

- Ensure PowerShell execution policy allows script running: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- Use Git Bash or WSL for Unix-like commands
- Docker Desktop works on Windows with WSL2 backend

### Installation

1. Clone the repository:
   ```bash
   git clone <repo-url>
   cd autopredator-monorepo
   ```

2. Install dependencies:
   ```bash
   # For web app
   cd apps/web
   npm install

   # For API
   cd ../api
   pip install -r requirements.txt
   ```

3. Set up environment variables:
   - Copy `.env.example` to `.env` in each app directory
   - Fill in required values

### Running Locally

```bash
# Web app
cd apps/web
npm run dev

# API
cd apps/api
python main.py

# Workers (if applicable)
cd apps/workers
python worker.py
```

### Common Commands

- `npm run lint` - Lint code
- `npm run format` - Format code
- `npm run test` - Run tests
- `npm run build` - Build for production

For API:
- `ruff check` - Lint Python code
- `black --check` - Check formatting
- `mypy` - Type check
- `pytest` - Run tests

## Development

See `docs/Development_plan.md` for detailed development guidelines, branching strategy, and contribution rules.

## Documentation

- [API Documentation](docs/API.md)
- [Data Model](docs/Data_model.md)
- [Deployment](docs/Deployment.md)
- [Security](docs/Security.md)
- [Data Layer Architecture](docs/DB_ARCHITECTURE.md)
- [Seeding](docs/SEEDING.md)

## How to run local data layer

1. Copy `infra/.env.example` to `infra/.env` and set strong passwords/secrets.
2. Start services: `make infra-up` (runs `infra/docker-compose.yml`).
3. Install script deps (for migrations/indexing/tests): `pip install -r scripts/requirements.txt`.
4. Apply schema + seeds via Flyway: `make db-migrate`.
5. Rebuild search indexes from Postgres: `make search-reindex`.
6. Validate connectivity to Postgres/Redis/OpenSearch/ClickHouse/MinIO: `make smoke-test`.

## CI/CD

GitHub Actions workflows handle linting, testing, building, and deployment. See `.github/workflows/` for details.
