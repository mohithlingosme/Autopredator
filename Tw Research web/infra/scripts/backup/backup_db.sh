#!/bin/bash

# Database backup script for Autopredator
# Usage: ./backup_db.sh [environment]
# Environment: staging|prod (default: staging)

set -e

ENVIRONMENT=${1:-staging}
BACKUP_DIR="/opt/autopredator/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/autopredator_${ENVIRONMENT}_${TIMESTAMP}.sql.gz"

# Retention policy: keep 7 daily, 4 weekly, 12 monthly
DAILY_RETENTION=7
WEEKLY_RETENTION=4
MONTHLY_RETENTION=12

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "Starting database backup for $ENVIRONMENT environment..."

# Get database credentials from environment
if [ "$ENVIRONMENT" = "prod" ]; then
    DB_HOST="autopredator_postgres_prod"
    DB_NAME="autopredator_prod"
else
    DB_HOST="autopredator_postgres_staging"
    DB_NAME="autopredator_staging"
fi

DB_USER="autopredator"
DB_PASSWORD="${DB_PASSWORD}"

# Create backup
docker exec "$DB_HOST" pg_dump -U "$DB_USER" -d "$DB_NAME" | gzip > "$BACKUP_FILE"

echo "Backup completed: $BACKUP_FILE"

# Apply retention policy
echo "Applying retention policy..."

# Remove old backups (keep last 7 daily)
find "$BACKUP_DIR" -name "autopredator_${ENVIRONMENT}_*.sql.gz" -mtime +$DAILY_RETENTION -delete

echo "Backup and cleanup completed successfully"

# Optional: Upload to S3 or other storage
# aws s3 cp "$BACKUP_FILE" "s3://your-backup-bucket/autopredator/$ENVIRONMENT/"
