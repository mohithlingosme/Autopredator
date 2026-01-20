# Deployment Guide

This document covers deployment strategies, environments, and operational procedures.

## Environments

### Local
- Location: Developer machines
- Purpose: Feature development and unit testing
- Data: Mock/test data
- Access: Developers only
- Hosting: Docker Compose on local machine
- Domain: localhost (ports 3000 for web, 8000 for api)

### Dev (Optional)
- Location: Shared dev server
- Purpose: Integration testing before staging
- Data: Test data
- Access: Team members
- Hosting: VPS + Docker Compose
- Domain: dev.example.com
- Deployment: On push to dev branch

### Staging
- Location: Cloud staging environment (VPS)
- Purpose: Pre-production testing and QA
- Data: Production-like data (anonymized)
- Access: Team members + stakeholders
- Hosting: VPS + Docker Compose
- Domain: staging.example.com
- Deployment: On merge to dev branch

### Production
- Location: Cloud production environment (VPS)
- Purpose: Live user traffic
- Data: Real user data
- Access: Restricted, monitored
- Hosting: VPS + Docker Compose
- Domain: example.com (or www.example.com)
- Deployment: On SemVer tags (e.g., v1.0.0)

## Hosting Strategy
- **Primary**: VPS (e.g., DigitalOcean, Linode, AWS EC2) + Docker Compose
- **Why**: Simple, cost-effective for small teams, easy to operate without Kubernetes overhead
- **Scaling**: Start with 1-2 vCPUs, 2-4GB RAM, 50-100GB SSD per environment
- **Backup**: Automated DB backups to object storage (e.g., S3-compatible)
- **Monitoring**: Basic uptime checks, error logs via Docker logging

## Domain and Subdomain Plan
- Production: example.com (main domain)
- Staging: staging.example.com
- Dev: dev.example.com (if needed)
- API: api.example.com (or /api on main domain via reverse proxy)
- SSL: Let's Encrypt certificates for all domains

## Deployment Triggers
- **Staging**: Automatic on merge to `dev` branch
- **Production**: Manual trigger on SemVer tags (e.g., `v1.2.3`)
- **Rollback**: Redeploy previous tag/image

## Tenancy Considerations
- **MVP**: Single-tenant (one org per deployment)
- **Future**: Multi-tenant support via database schema isolation or separate DBs
- **Infra Impact**: Single-tenant simplifies networking, secrets, and backups

## Deployment Process

### Automated Deployment
1. Code pushed to main branch
2. CI pipeline runs tests and builds
3. Artifacts deployed to staging
4. Manual approval for production
5. Blue-green deployment to production

### Rollback Procedure
1. Identify issue and deployment version
2. Execute rollback command
3. Monitor system health
4. Investigate root cause
5. Plan fix and redeploy

## Infrastructure

### Web Application
- Platform: VPS + Docker Compose
- Container: Node.js + Next.js
- Scaling: Single instance (MVP), horizontal later
- CDN: Cloudflare or similar (future)

### API
- Platform: VPS + Docker Compose
- Container: Python + FastAPI
- Scaling: Single instance (MVP), horizontal later
- Framework: FastAPI with Uvicorn

### Workers
- Platform: VPS + Docker Compose
- Container: Python + Celery
- Queue: Redis
- Scaling: 1-2 replicas (configurable in compose)

### Database
- Type: PostgreSQL 15
- Hosting: Docker container on VPS
- Backup: Automated daily via infra/scripts/backup/backup_db.sh
- Retention: 7 daily backups
- Migration: Alembic (run manually on deploy or via CI)
- Health checks: pg_isready in compose

### Cache/Queue
- Type: Redis 7
- Usage: API caching + Celery queue
- Hosting: Docker container on VPS
- Persistence: Named volumes
- Health checks: redis-cli ping

### Reverse Proxy
- Type: Traefik v2.10
- TLS: Let's Encrypt automatic certificates
- Routing: Host-based + path-based (/api)
- Security: Basic headers (X-Frame-Options, etc.)

## Monitoring

### Health Checks
- Application endpoints: `/health`
- Database connectivity
- External service dependencies
- Resource utilization

### Alerts
- Error rate thresholds
- Response time degradation
- Resource exhaustion
- Security incidents

## Security

- SSL/TLS encryption
- Access control and authentication
- Regular security updates
- Vulnerability scanning
- Log monitoring for anomalies
