# Deployment - AutoPredator FleetCommand

## Overview

This document outlines the deployment strategy for FleetCommand, including infrastructure setup, CI/CD pipelines, and operational procedures.

## Infrastructure Architecture

### Production Environment

```
┌─────────────────────────────────────────────────────────────┐
│                    External Users                           │
└─────────────────────┬───────────────────────────────────────┘
                      │
             ┌────────▼────────┐
             │   CloudFront    │  CDN for static assets
             │   (CDN)         │
             └────────┬────────┘
                      │
             ┌────────▼────────┐
             │   ALB/ELB       │  Application Load Balancer
             │   (Load         │
             │    Balancer)    │
             └────────┬────────┘
                      │
        ┌─────────────┼─────────────┐
        │             │             │
┌───────▼──────┐ ┌────▼────┐ ┌─────▼─────┐
│   Web App    │ │  API   │ │   Worker   │
│  (Next.js)   │ │(FastAPI)│ │ (Python)  │
│              │ │        │ │            │
│   ECS Fargate│ │ECS     │ │ECS Fargate │
│   Service    │ │Fargate │ │Service     │
└───────┬──────┘ └────┬───┘ └─────┬──────┘
        │             │             │
        └─────────────┼─────────────┘
                      │
             ┌────────▼────────┐
             │   PostgreSQL    │  Amazon RDS
             │   (Database)    │
             └────────┬────────┘
                      │
             ┌────────▼────────┐
             │     Redis       │  Amazon ElastiCache
             │   (Cache)       │
             └─────────────────┘
```

### Infrastructure Components

- **Load Balancer**: AWS Application Load Balancer for traffic distribution
- **CDN**: Amazon CloudFront for global content delivery
- **Compute**: AWS ECS Fargate for serverless container execution
- **Database**: Amazon RDS PostgreSQL with Multi-AZ deployment
- **Cache**: Amazon ElastiCache Redis for session and data caching
- **Storage**: Amazon S3 for file uploads and static assets
- **Monitoring**: AWS CloudWatch for logs and metrics

## Environment Configuration

### Environment Variables

**API Service (.env):**
```bash
# Database
DATABASE_URL=postgresql://user:password@host:5432/fleetcommand

# Redis
REDIS_URL=redis://host:6379

# Authentication
JWT_SECRET_KEY=your-secret-key-here
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=15
JWT_REFRESH_TOKEN_EXPIRE_DAYS=7

# CORS
CORS_ORIGINS=https://app.fleetcommand.com

# AWS
AWS_REGION=us-east-1
AWS_S3_BUCKET=fleetcommand-uploads

# Email
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# Monitoring
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id
```

**Web Application (.env):**
```bash
# API Configuration
NEXT_PUBLIC_API_URL=https://api.fleetcommand.com

# Authentication
NEXTAUTH_URL=https://app.fleetcommand.com
NEXTAUTH_SECRET=your-nextauth-secret

# Analytics (optional)
GOOGLE_ANALYTICS_ID=GA_MEASUREMENT_ID
```

**Worker Service (.env):**
```bash
# Database
DATABASE_URL=postgresql://user:password@host:5432/fleetcommand

# Redis
REDIS_URL=redis://host:6379

# AWS
AWS_REGION=us-east-1
AWS_S3_BUCKET=fleetcommand-uploads

# Email
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

## Containerization

### Dockerfile Examples

**API Service:**
```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create non-root user
RUN useradd --create-home --shell /bin/bash app && chown -R app:app /app
USER app

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Web Application:**
```dockerfile
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Build application
RUN npm run build

# Production image
FROM node:18-alpine AS runner

WORKDIR /app

# Copy built application
COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

EXPOSE 3000

CMD ["npm", "start"]
```

**Worker Service:**
```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create non-root user
RUN useradd --create-home --shell /bin/bash app && chown -R app:app /app
USER app

CMD ["python", "worker.py"]
```

## CI/CD Pipeline

### GitHub Actions Workflow

**.github/workflows/deploy.yml:**
```yaml
name: Deploy to Production

on:
  push:
    branches: [ main ]
  workflow_dispatch:

env:
  AWS_REGION: us-east-1
  ECR_REPOSITORY: fleetcommand

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install -r apps/api/requirements-dev.txt

      - name: Run tests
        run: |
          cd apps/api
          pytest

  build-and-push:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      - name: Build and push API image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: ${{ env.ECR_REPOSITORY }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY/api:latest ./apps/api
          docker push $ECR_REGISTRY/$ECR_REPOSITORY/api:latest

      - name: Build and push Web image
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY/web:latest ./apps/web
          docker push $ECR_REGISTRY/$ECR_REPOSITORY/web:latest

      - name: Build and push Worker image
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY/worker:latest ./apps/worker
          docker push $ECR_REGISTRY/$ECR_REPOSITORY/worker:latest

  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest
    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Update ECS services
        run: |
          aws ecs update-service --cluster fleetcommand --service api --force-new-deployment
          aws ecs update-service --cluster fleetcommand --service web --force-new-deployment
          aws ecs update-service --cluster fleetcommand --service worker --force-new-deployment
```

## Database Management

### Migrations

**Alembic Configuration:**
```python
# alembic.ini
[alembic]
script_location = app/db/migrations
sqlalchemy.url = %(DATABASE_URL)s

[loggers]
keys = root,sqlalchemy,alembic

[handlers]
keys = console

[formatters]
keys = generic

[logger_root]
level = WARN
handlers = console
qualifier = %(levelname)s

[logger_sqlalchemy]
level = WARN
handlers =
qualifier = %(levelname)s

[logger_alembic]
level = INFO
handlers =
qualifier = %(levelname)s

[handler_console]
class = StreamHandler
args = (sys.stderr,)
level = NOTSET
formatter = generic
qualifier = %(levelname)s

[formatter_generic]
format = %(levelname)-5.5s [%(name)s] %(message)s
datefmt = %H:%M:%S
```

**Migration Commands:**
```bash
# Generate migration
alembic revision --autogenerate -m "Add vehicles table"

# Run migrations
alembic upgrade head

# Rollback migration
alembic downgrade -1
```

### Backup Strategy

**Automated Backups:**
```bash
# Daily backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="fleetcommand_backup_$DATE.sql"

pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME > $BACKUP_FILE

# Upload to S3
aws s3 cp $BACKUP_FILE s3://fleetcommand-backups/

# Clean up old backups (keep last 30 days)
aws s3 ls s3://fleetcommand-backups/ | while read -r line; do
    createDate=`echo $line | awk {'print $1" "$2'}`
    createDate=`date -d"$createDate" +%s`
    olderThan=`date -d'30 days ago' +%s`
    if [[ $createDate -lt $olderThan ]]; then
        fileName=`echo $line | awk {'print $4'}`
        if [[ $fileName != "" ]]; then
            aws s3 rm s3://fleetcommand-backups/$fileName
        fi
    fi
done
```

## Monitoring and Observability

### Application Monitoring

**Health Checks:**
```python
# FastAPI health endpoint
@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@app.get("/ready")
async def readiness_check(db: Session = Depends(get_db)):
    try:
        # Check database connectivity
        db.execute("SELECT 1")
        return {"status": "ready"}
    except Exception:
        raise HTTPException(status_code=503, detail="Database not ready")
```

### Logging Configuration

**Structured Logging:**
```python
import logging
import json
from pythonjsonlogger import jsonlogger

logger = logging.getLogger()
logHandler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter(
    "%(asctime)s %(name)s %(levelname)s %(message)s"
)
logHandler.setFormatter(formatter)
logger.addHandler(logHandler)
logger.setLevel(logging.INFO)
```

### Metrics Collection

**Key Metrics:**
- API response times
- Error rates
- Database connection pool usage
- Queue lengths
- Memory and CPU usage

## Scaling Strategy

### Horizontal Scaling

**ECS Service Configuration:**
```yaml
# ecs-service.yml
api:
  cpu: 256
  memory: 512
  desired_count: 3
  min_capacity: 1
  max_capacity: 10

web:
  cpu: 256
  memory: 512
  desired_count: 2
  min_capacity: 1
  max_capacity: 5

worker:
  cpu: 256
  memory: 512
  desired_count: 1
  min_capacity: 1
  max_capacity: 3
```

### Auto Scaling

**CPU Utilization Scaling:**
```yaml
# Auto scaling policy
api_scaling_policy:
  policy_type: TargetTrackingScaling
  target_tracking_scaling_policy_configuration:
    target_value: 70.0
    predefined_metric_specification:
      predefined_metric_type: ECSServiceAverageCPUUtilization
```

## Security in Deployment

### Secrets Management

**AWS Systems Manager Parameter Store:**
```bash
# Store secrets
aws ssm put-parameter \
    --name "/fleetcommand/prod/database/password" \
    --value "my-secret-password" \
    --type "SecureString"

# Retrieve in application
import boto3
ssm = boto3.client('ssm')
response = ssm.get_parameter(
    Name='/fleetcommand/prod/database/password',
    WithDecryption=True
)
db_password = response['Parameter']['Value']
```

### Network Security

**Security Groups:**
```bash
# ALB Security Group
aws ec2 create-security-group \
    --group-name fleetcommand-alb-sg \
    --description "Security group for ALB"

aws ec2 authorize-security-group-ingress \
    --group-id $ALB_SG_ID \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

# ECS Security Group
aws ec2 create-security-group \
    --group-name fleetcommand-ecs-sg \
    --description "Security group for ECS tasks"

aws ec2 authorize-security-group-ingress \
    --group-id $ECS_SG_ID \
    --protocol tcp \
    --port 8000 \
    --source-group $ALB_SG_ID
```

## Disaster Recovery

### Backup and Restore

**Database Recovery:**
```bash
# Restore from backup
psql -h $DB_HOST -U $DB_USER -d $DB_NAME < backup_file.sql

# Point-in-time recovery
aws rds restore-db-instance-to-point-in-time \
    --source-db-instance-identifier fleetcommand-prod \
    --target-db-instance-identifier fleetcommand-restore \
    --restore-time 2023-12-01T00:00:00Z
```

### Failover Strategy

**Multi-AZ Deployment:**
- PostgreSQL with synchronous replication
- Automatic failover within same region
- Cross-region replication for critical data

## Cost Optimization

### Resource Optimization

**Reserved Instances:**
```bash
# Purchase RI for steady-state workloads
aws ec2 purchase-reserved-instances-offering \
    --reserved-instances-offering-id $OFFERING_ID \
    --instance-count 1
```

**Spot Instances for Workers:**
```bash
# Use spot instances for worker nodes
aws ecs create-service \
    --service-name worker \
    --task-definition worker:1 \
    --desired-count 2 \
    --capacity-provider-strategy [
        {
            "capacityProvider": "FARGATE_SPOT",
            "weight": 1
        }
    ]
```

### Monitoring Costs

**Cost Allocation Tags:**
```bash
# Tag resources for cost tracking
aws ec2 create-tags \
    --resources $INSTANCE_ID \
    --tags Key=Environment,Value=production Key=Application,Value=fleetcommand
```

This deployment strategy ensures reliable, scalable, and secure operation of FleetCommand in production.
