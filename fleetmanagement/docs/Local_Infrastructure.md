# Local Infrastructure

This document describes the local development infrastructure for AutoPredator FleetCommand.

## Prerequisites

- **Docker & Docker Compose**: Required for running services
- **Node.js 18+**: Use `.nvmrc` for version management
- **Python 3.11+**: For API backend
- **Git**: For version control

### Windows Users
- Install Docker Desktop for Windows
- Use Git Bash or WSL2 for running shell scripts
- Scripts are bash-compatible but may need adjustments

## Quick Start

1. **Clone and Bootstrap**
   ```bash
   git clone <repo>
   cd autopredator-fleetmanagement
   ./scripts/bootstrap.sh
   ```

2. **Start Development**
   ```bash
   ./scripts/dev.sh
   ```

3. **Verify Setup**
   ```bash
   ./scripts/smoke.sh
   ```

4. **Reset Everything**
   ```bash
   ./scripts/reset.sh
   ```

## Services

| Service | URL | Purpose |
|---------|-----|---------|
| API | http://localhost:8000 | FastAPI backend |
| Web | http://localhost:3000 | Next.js frontend |
| Postgres | localhost:5432 | Database |
| Redis | localhost:6379 | Cache/Queue |
| Adminer | http://localhost:8080 | DB Admin UI |
| Mailpit | http://localhost:8025 | Email Testing UI |
| MinIO | http://localhost:9000 | Object Storage API |
| MinIO Console | http://localhost:9001 | Object Storage UI |

## Environment Variables

Copy `.env.example` to `.env.local` and adjust as needed:

- **Database**: `DATABASE_URL` for Postgres connection
- **Redis**: `REDIS_URL` for cache/queue
- **Email**: `SMTP_*` for Mailpit configuration
- **Storage**: `STORAGE_*` for MinIO S3-compatible storage
- **Auth**: `JWT_*` for token configuration
- **Dev**: `DEV_AUTH=true` enables magic login

## Database

### Migrations
```bash
cd apps/api
alembic revision --autogenerate -m "migration message"
alembic upgrade head
```

### Seeding
```bash
cd apps/api
python seed.py
```

Seeds demo data:
- 1 tenant (Demo Company)
- 3 users: admin@autopredator.dev, manager@autopredator.dev, driver@autopredator.dev
- 1 vehicle, 1 driver profile, 1 sample trip

## Development Workflow

1. **Bootstrap** once after cloning
2. **Develop** with `./scripts/dev.sh` (runs API + Web + Worker)
3. **Test** with `./scripts/smoke.sh`
4. **Reset** if needed with `./scripts/reset.sh`

## Troubleshooting

### Docker Issues
- Ensure Docker Desktop is running
- Check ports aren't in use: `netstat -an | grep :5432`
- On Windows/WSL2: Ensure Docker integration is enabled

### Permission Issues
- Scripts need execute permissions: `chmod +x scripts/*.sh`
- On Windows: Run in Git Bash or WSL

### Service Health
- Check logs: `docker compose -f infra/docker-compose.yml logs <service>`
- Restart services: `docker compose -f infra/docker-compose.yml restart`

### Database Issues
- Reset DB: `./scripts/reset.sh` then `./scripts/bootstrap.sh`
- Manual migration: `cd apps/api && alembic upgrade head`

### Port Conflicts
- Change ports in `infra/docker-compose.yml` if needed
- Update `.env.example` accordingly

## Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Web (3000)    │    │   API (8000)    │
│   Next.js       │◄──►│   FastAPI       │
└─────────────────┘    └─────────────────┘
         │                       │
         └───────────────────────┼───────────────────────┐
                                 │                       │
                    ┌────────────▼────────────┐ ┌────────▼────────────┐
                    │    Postgres (5432)     │ │   Redis (6379)      │
                    │    Database            │ │   Cache/Queue       │
                    └─────────────────────────┘ └─────────────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │   Mailpit (1025/8025)  │
                    │   Email Testing        │
                    └─────────────────────────┘
```

## CI/CD

Local infra scripts are designed not to interfere with CI:
- Scripts check for Docker availability
- Optional dependencies don't break builds
- Use `make` commands for CI compatibility

## Security

- Never commit `.env*` files
- Use `.env.example` as template
- Secrets are local-only; production uses different mechanisms
- Database seeded with dev credentials only

## Contributing

1. Follow the setup above
2. Run `./scripts/smoke.sh` before committing
3. Update this doc if you change infrastructure
