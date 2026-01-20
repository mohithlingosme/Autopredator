# AutoPredator FleetCommand

A multi-tenant fleet management platform designed for Indian businesses, focusing on vehicle tracking, maintenance, fuel management, and compliance with strict data privacy.

## Features

- Multi-company tenancy with strict data isolation
- Vehicle management (registration, insurance, permits, fitness, PUC)
- Driver management and trip logging
- Fuel and maintenance tracking
- Document management with expiry alerts
- Dashboard and reporting
- Email notifications for expiries

## Tech Stack

- **Backend**: FastAPI (Python)
- **Frontend**: Next.js (React)
- **Database**: PostgreSQL
- **Queue**: Redis + RQ
- **Deployment**: Docker + VPS

## Local Development

See [Local Infrastructure](docs/Local_Infrastructure.md) for detailed setup.

### Prerequisites

- Docker & Docker Compose
- Node.js 18+ (use `.nvmrc`)
- Python 3.11+

### Quick Setup

1. Clone the repo
2. Run `./scripts/bootstrap.sh` (sets up everything)
3. Run `./scripts/dev.sh` (starts development servers)
4. Run `./scripts/smoke.sh` (verifies setup)

### Commands

- `./scripts/bootstrap.sh` - Bootstrap local infra
- `./scripts/dev.sh` - Start development servers
- `./scripts/smoke.sh` - Run smoke tests
- `./scripts/reset.sh` - Reset local infra
- `make install` - Install dependencies
- `make lint` - Run linters
- `make test` - Run tests
- `make build` - Build for production
- `make run` - Run in development mode

## Architecture

Monorepo structure:
- `apps/api` - FastAPI backend
- `apps/web` - Next.js frontend
- `apps/worker` - Background job processor
- `packages/shared` - Shared utilities
- `infra` - Infrastructure as code
- `docs` - Documentation

## Deployment

See `docs/Deployment.md` for VPS + Docker setup.

## Contributing

See `CONTRIBUTING.md` for guidelines.

## License

MIT
