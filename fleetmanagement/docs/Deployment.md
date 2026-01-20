# Deployment Guide

This guide covers deploying AutoPredator FleetCommand to a VPS using Docker and Docker Compose.

## Prerequisites

- VPS with Ubuntu 22.04+ (2GB RAM minimum, 4GB recommended)
- Domain name pointing to VPS IP
- SSH access to server
- Docker and Docker Compose installed

## Server Setup

### 1. Update System
```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Install Docker
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

### 3. Install Docker Compose
```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 4. Install Nginx
```bash
sudo apt install nginx -y
```

### 5. Install Certbot (Let's Encrypt)
```bash
sudo apt install certbot python3-certbot-nginx -y
```

## Application Deployment

### 1. Clone Repository
```bash
git clone https://github.com/your-org/fleetmanagement.git
cd fleetmanagement
```

### 2. Environment Configuration
Create `.env` file:
```bash
cp .env.example .env
nano .env
```

Required environment variables:
```env
# Database
POSTGRES_DB=fleetcommand
POSTGRES_USER=fleetuser
POSTGRES_PASSWORD=secure_password_here
DATABASE_URL=postgresql://fleetuser:secure_password_here@db:5432/fleetcommand

# Redis
REDIS_URL=redis://redis:6379

# JWT
JWT_SECRET_KEY=your_super_secret_jwt_key_here
JWT_REFRESH_SECRET_KEY=your_refresh_secret_key_here

# Email (SMTP)
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your_email@gmail.com
SMTP_PASSWORD=your_app_password

# Application
APP_ENV=production
DOMAIN=yourdomain.com
API_URL=https://api.yourdomain.com
WEB_URL=https://yourdomain.com

# Admin Setup
ADMIN_EMAIL=admin@yourcompany.com
ADMIN_PASSWORD=initial_admin_password
```

### 3. Docker Compose Setup
The `docker-compose.prod.yml` includes:
- PostgreSQL database
- Redis cache/queue
- API backend
- Web frontend
- Worker for background jobs
- Nginx reverse proxy

Deploy with:
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### 4. Database Migration
Run initial migrations:
```bash
docker-compose -f docker-compose.prod.yml exec api alembic upgrade head
```

### 5. Seed Data
Create initial admin user and sample data:
```bash
docker-compose -f docker-compose.prod.yml exec api python scripts/seed.py
```

## Nginx Configuration

### 1. SSL Certificate
```bash
sudo certbot --nginx -d yourdomain.com -d api.yourdomain.com
```

### 2. Nginx Config
Create `/etc/nginx/sites-available/fleetcommand`:
```nginx
upstream api_backend {
    server api:8000;
}

upstream web_frontend {
    server web:3000;
}

server {
    listen 80;
    server_name yourdomain.com api.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://web_frontend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /api {
        proxy_pass http://api_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 443 ssl http2;
    server_name api.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://api_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/fleetcommand /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## Backup Strategy

### Database Backup
Create backup script `/opt/fleetcommand/backup.sh`:
```bash
#!/bin/bash
BACKUP_DIR="/opt/fleetcommand/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/fleetcommand_$DATE.sql"

mkdir -p $BACKUP_DIR

docker-compose -f /opt/fleetcommand/docker-compose.prod.yml exec -T db pg_dump -U fleetuser fleetcommand > $BACKUP_FILE

# Encrypt backup
gpg --encrypt --recipient your_backup_key $BACKUP_FILE

# Remove unencrypted file
rm $BACKUP_FILE

# Keep only last 30 days
find $BACKUP_DIR -name "*.gpg" -mtime +30 -delete

echo "Backup completed: $BACKUP_FILE.gpg"
```

Make executable and schedule:
```bash
chmod +x /opt/fleetcommand/backup.sh
crontab -e
# Add: 0 2 * * * /opt/fleetcommand/backup.sh
```

### File Backup
Documents are stored in Docker volumes. Backup with:
```bash
docker run --rm -v fleetcommand_uploads:/data -v /opt/backups:/backup alpine tar czf /backup/uploads_$(date +%Y%m%d).tar.gz -C /data .
```

## Monitoring & Maintenance

### Health Checks
- API health: `https://api.yourdomain.com/health`
- Web health: `https://yourdomain.com/api/health`

### Logs
View application logs:
```bash
docker-compose -f docker-compose.prod.yml logs -f api
docker-compose -f docker-compose.prod.yml logs -f web
```

### Updates
1. Pull latest changes: `git pull`
2. Rebuild: `docker-compose -f docker-compose.prod.yml up -d --build`
3. Run migrations: `docker-compose -f docker-compose.prod.yml exec api alembic upgrade head`

### Scaling
For high traffic, scale API containers:
```bash
docker-compose -f docker-compose.prod.yml up -d --scale api=3
```

## Troubleshooting

### Common Issues
- **Port conflicts**: Check if ports 80/443 are free
- **SSL issues**: Verify domain DNS and certbot logs
- **Database connection**: Check DATABASE_URL in .env
- **Memory issues**: Monitor with `docker stats`

### Logs Location
- Nginx: `/var/log/nginx/`
- Application: `docker-compose logs`
- System: `/var/log/syslog`

This deployment provides a production-ready setup with high availability, security, and monitoring capabilities.
