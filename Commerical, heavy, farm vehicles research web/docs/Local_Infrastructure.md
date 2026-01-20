# Local Infrastructure Setup

This document describes the local development environment for the AutoPredator FleetCommand monorepo project.

## Prerequisites

### Required Installations

- **Git**: Version control system
  - Download: https://git-scm.com/downloads
  - Verify: `git --version`

- **Node.js LTS**: JavaScript runtime (v18+ recommended)
  - Download: https://nodejs.org/
  - Verify: `node --version` and `npm --version`
  - Includes npm package manager

- **pnpm**: Fast, disk-efficient package manager
  - Install: `npm install -g pnpm`
  - Verify: `pnpm --version`

- **Python 3.11+**: Programming language for API and worker
  - Download: https://python.org/downloads/
  - Verify: `python --version` (should be 3.11 or higher)
  - Ensure `pip` is installed

- **Docker**: Containerization platform
  - Download: https://docker.com/get-started
  - Verify: `docker --version`

- **Docker Compose**: Multi-container orchestration
  - Usually included with Docker Desktop
  - Verify: `docker compose version` or `docker-compose --version`

### Recommended Tools

- **psql**: PostgreSQL command-line client
  - Install via your package manager or PostgreSQL installer
  - Verify: `psql --version`

- **redis-cli**: Redis command-line client
  - Install via your package manager or Redis installer
  - Verify: `redis-cli --version`

- **DBeaver or TablePlus**: Database GUI clients
  - DBeaver: https://dbeaver.io/
  - TablePlus: https://tableplus.com/

## Quick Start

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd autopredator-fleetcommand
   ```

2. Run the doctor script to verify your setup:
   ```bash
   pnpm doctor
   ```

3. Bootstrap the development environment:
   ```bash
   pnpm bootstrap
   ```

4. Access the services:
   - API: http://localhost:8000
   - Web: http://localhost:3000
   - API Docs: http://localhost:8000/docs

## Available Scripts

Run these from the repository root:

- `pnpm doctor` - Verify all prerequisites are installed
- `pnpm bootstrap` - Set up the entire local environment
- `pnpm reset` - Reset the local environment (removes data)
- `pnpm dev` - Start development servers
- `pnpm up` - Start Docker services
- `pnpm down` - Stop Docker services
- `pnpm logs` - View Docker service logs
- `pnpm db:migrate` - Run database migrations
- `pnpm db:reset` - Reset database schema
- `pnpm seed` - Seed database with demo data
- `pnpm test:all` - Run all tests
- `pnpm lint:all` - Run all linters
- `pnpm typecheck:all` - Run all type checkers

## Environment Variables

The project uses `.env` files for configuration. Examples are provided:

- `apps/api/.env.example`
- `apps/web/.env.example`
- `apps/worker/.env.example`

Copy these to `.env` files and customize as needed:

```bash
cp apps/api/.env.example apps/api/.env
cp apps/web/.env.example apps/web/.env
cp apps/worker/.env.example apps/worker/.env
```

## Database Access

### From Host Machine

- PostgreSQL: `postgresql://postgres:password@localhost:5432/fleetcommand`
- Redis: `redis://localhost:6379`

### From Containers

- PostgreSQL: `postgresql://postgres:password@postgres:5432/fleetcommand`
- Redis: `redis://redis:6379`

## Troubleshooting

### Common Issues

1. **Port conflicts**
   - Ensure ports 5432, 6379, 8000, 3000 are available
   - Check with: `netstat -an | grep LISTEN` (Linux/Mac) or `netstat -an` (Windows)

2. **Docker permission issues**
   - Linux: Add user to docker group: `sudo usermod -aG docker $USER`
   - Windows/Mac: Ensure Docker Desktop is running

3. **Python virtual environment issues**
   - Ensure you're using Python 3.11+
   - Try: `python -m venv venv && source venv/bin/activate` (Linux/Mac) or `python -m venv venv && venv\Scripts\activate` (Windows)

4. **Node.js/npm version issues**
   - Use nvm (Node Version Manager): https://github.com/nvm-sh/nvm
   - Install specific version: `nvm install 18 && nvm use 18`

5. **pnpm installation issues**
   - Alternative: `npm install -g pnpm`
   - Or use corepack: `corepack enable && corepack prepare pnpm@latest --activate`

### Resetting the Environment

If you encounter persistent issues:

```bash
pnpm reset  # This will remove all data and restart
```

### Checking Service Health

- API health: `curl http://localhost:8000/health`
- API readiness: `curl http://localhost:8000/ready`
- Docker services: `docker compose ps`

### Logs and Debugging

- View all logs: `pnpm logs`
- View specific service logs: `docker compose logs <service-name>`
- API logs include correlation IDs for request tracing

### Windows-Specific Notes

- Use Git Bash or WSL for shell scripts
- Docker Desktop for Windows works well
- Python installation: Use the official installer from python.org
- Ensure long paths are enabled in Windows settings

### macOS-Specific Notes

- Use Homebrew for package management: `brew install git node pnpm python postgresql redis`
- Docker Desktop for Mac works well
- Python: Use `brew install python@3.11`

### Linux-Specific Notes

- Use your distribution's package manager
- Ubuntu/Debian: `sudo apt update && sudo apt install git nodejs npm python3 postgresql-client redis-tools`
- Docker: Follow official installation guide
- Add user to docker group as mentioned above

## Development Workflow

1. Make code changes
2. Run tests: `pnpm test:all`
3. Run linters: `pnpm lint:all`
4. Check types: `pnpm typecheck:all`
5. Commit and push

## Contributing

- Follow the coding standards in `docs/coding_standards.md`
- Ensure all tests pass before submitting PRs
- Update documentation as needed
