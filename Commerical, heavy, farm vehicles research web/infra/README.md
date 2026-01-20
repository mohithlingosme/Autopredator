# Infrastructure for AutoPredator FleetCommand

This directory contains the infrastructure-as-code for deploying AutoPredator FleetCommand to VPS servers (staging and production).

## Overview

- **Reverse Proxy**: Caddy (automatic HTTPS, easy config)
- **Containers**: Docker + Docker Compose
- **Database**: PostgreSQL
- **Cache/Queue**: Redis
- **Services**: web (Next.js), api (FastAPI), worker (Python)
- **CI/CD**: GitHub Actions (build/push images + SSH deploy)
- **Domains**: `app.<domain>` → web, `api.<domain>` → api

## Prerequisites

- VPS with Ubuntu 22.04+ (or similar Linux)
- Root access for initial setup
- Domain(s) pointing to VPS IP (DNS A records for `app` and `api` subdomains)
- GitHub repository with secrets configured

## Server Hardening Checklist

Run these commands as root on a fresh VPS:

### 1. Create Deploy User
```bash
adduser deploy
usermod -aG sudo deploy
mkdir -p /home/deploy/.ssh
chmod 700 /home/deploy/.ssh
# Add your public SSH key to /home/deploy/.ssh/authorized_keys
chown -R deploy:deploy /home/deploy/.ssh
chmod 600 /home/deploy/.ssh/authorized_keys
```

### 2. Disable Root Login & Password Auth
Edit `/etc/ssh/sshd_config`:
```
PermitRootLogin no
PasswordAuthentication no
```
Then: `systemctl reload sshd`

### 3. Firewall (UFW)
```bash
ufw allow 22/tcp  # SSH
ufw allow 80/tcp  # HTTP
ufw allow 443/tcp # HTTPS
ufw --force enable
```

### 4. Directory Layout
```bash
mkdir -p /opt/fleetcommand/{configs,logs,data,backups}
chown -R deploy:deploy /opt/fleetcommand
```

### 5. Time Sync & Monitoring
```bash
apt update && apt install -y ntp htop iotop
# Enable NTP: systemctl enable ntp
# Basic monitoring: htop, journalctl -f
```

### 6. Docker & Compose
```bash
curl -fsSL https://get.docker.com | sh
usermod -aG docker deploy
apt install -y docker-compose-plugin
```

### 7. Lock Internal Ports
Ensure DB (5432) and Redis (6379) are NOT exposed publicly. Only 80/443/22 open.

## Deployment Workflow

1. Provision VPS using `infra/scripts/provision_vps.sh` or manual checklist above.
2. Set up DNS: Point `app.yourdomain.com` and `api.yourdomain.com` to VPS IP.
3. Configure GitHub Secrets: `SSH_PRIVATE_KEY`, `SERVER_HOST_STAGING`, `SERVER_HOST_PRODUCTION`, etc.
4. Push code: CI builds images, deploys to staging on merge to `main`.
5. Promote to production: Manual approval in GitHub Actions.

## Environment Variables

Copy `infra/environments/<env>/.env.example` to `.env` on server, fill in secrets.

Key vars:
- `DOMAIN`: Your domain (e.g., yourdomain.com)
- `DB_*`: PostgreSQL credentials
- `JWT_SECRET_KEY`: Random string
- `CORS_ORIGINS`: Allowed origins for API

## Monitoring & Logs

- Health checks: `infra/scripts/healthcheck.sh`
- Logs: `docker-compose logs -f`
- Backups: See `infra/backups/README.md`

## Troubleshooting

- HTTPS issues: Check DNS propagation, Caddy logs.
- DB connection: Verify env vars, network.
- Rollback: Use `infra/scripts/rollback.sh` to previous image tag.
