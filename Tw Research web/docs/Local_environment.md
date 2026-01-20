# Local Environment Setup

This guide explains how to set up and run the Autopredator monorepo locally for development.

## Prerequisites

- **Git** - Version control system
- **Node.js** (see .nvmrc for version) - JavaScript runtime
- **Python** (see .python-version for version) - Python runtime
- **Docker Desktop** (recommended) - For local database and dependencies
- **VS Code** (recommended) - IDE with extensions for development

### One-time Install Instructions

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

## Environment Variables

### Naming Conventions

- Use `SCREAMING_SNAKE_CASE` for all environment variables
- Prefix with app name for app-specific vars (e.g., `API_DATABASE_URL`)
- Use descriptive names (e.g., `DATABASE_URL` instead of `DB_URL`)
- Required variables have no default; optional have defaults

### Required Variables

Copy `.env.example` files to `.env` in each app directory and fill in values:

- **Root**: Common configuration
- **apps/api**: API-specific settings (database, auth, external services)
- **apps/web**: Web-specific settings (API URLs, feature flags)

## Bootstrap

Install dependencies across the monorepo:

```bash
# Unix
./scripts/bootstrap.sh

# Windows
./scripts/bootstrap.ps1

# Or via npm
npm run bootstrap
```

## Database Setup

Start local database services:

```bash
# Start services
./scripts/db-up.sh  # or db-up.ps1

# Stop services
./scripts/db-down.sh  # or db-down.ps1

# Reset (removes all data)
./scripts/db-reset.sh  # or db-reset.ps1
```

Database connection info:
- **Postgres**: `postgresql://autopredator:password@localhost:5432/autopredator_dev`
- **Redis**: `redis://localhost:6379`

## Run Development Environment

Start all services concurrently:

```bash
# Unix
./scripts/dev.sh

# Windows
./scripts/dev.ps1

# Or via npm
npm run dev
```

This starts:
- Database services (via Docker Compose)
- API server (http://localhost:8000)
- Web app (http://localhost:3000)
- Workers (if configured)

## Run Checks

Run linting, formatting, type checking, and tests:

```bash
# Unix
./scripts/check.sh

# Windows
./scripts/check.ps1

# Or via npm
npm run check
```

## API Development

```bash
cd apps/api

# Install dependencies
make install  # or poetry install

# Run development server
make dev  # or poetry run uvicorn main:app --reload

# Run tests
make test  # or poetry run pytest

# Lint and format
make lint
make format
make typecheck
```

API endpoints:
- Health check: `GET /healthz`
- Readiness check: `GET /readyz`
- API docs: `GET /docs` (Swagger UI)

## Web Development

```bash
cd apps/web

# Install dependencies
npm install

# Run development server
npm run dev

# Run tests
npm run test

# Lint and format
npm run lint
npm run format
npm run typecheck
```

The web app proxies API requests to `http://localhost:8000` to avoid CORS issues.

## Worker Development

```bash
cd apps/workers

# Install dependencies
pip install -r requirements.txt

# Run worker
./scripts/worker-dev.sh  # or worker-dev.ps1
```

## Troubleshooting

### Port Conflicts

- API runs on port 8000
- Web runs on port 3000
- Postgres on 5432
- Redis on 6379

If ports are in use, update the respective configuration files.

### Docker Issues

- Ensure Docker Desktop is running
- On Windows, ensure WSL2 is enabled
- Check `docker-compose logs` for errors

### Environment Problems

- Ensure `.env` files are created from `.env.example`
- Check variable names match exactly
- Restart services after env changes

### Migration Issues

- Database schema changes require migrations
- Use Alembic for API database migrations
- Reset database with `scripts/db-reset.sh` for clean slate

## Test Users

For development, use these sample users:

- **Admin**: admin@autopredator.com / admin123
- **Manager**: manager@autopredator.com / manager123
- **Operator**: operator@autopredator.com / operator123
- **Driver**: driver@autopredator.com / driver123
- **Viewer**: viewer@autopredator.com / viewer123

Auth can be bypassed in development by setting `AUTH_ENABLED=false`.
