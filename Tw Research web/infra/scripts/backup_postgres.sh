#!/bin/bash
set -e

# PostgreSQL backup script for AutoPredator FleetCommand
# Usage: ./backup_postgres.sh [env]
# Default env: production

ENV=${1:-production}
BACKUP_DIR="/opt/fleetcommand/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="fleetcommand_${ENV}_${TIMESTAMP}.sql.gz"

# Load environment variables
if [ -f "/opt/fleetcommand/configs/.env" ]; then
    export $(grep -v '^#' /opt/fleetcommand/configs/.env | xargs)
else
    echo "❌ .env file not found at /opt/fleetcommand/configs/.env"
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "📦 Creating PostgreSQL backup: $BACKUP_NAME"

# Create backup with compression
docker exec fleetcommand_postgres_1 pg_dump \
    -U "$DB_USER" \
    -h localhost \
    "$DB_NAME" | gzip > "$BACKUP_DIR/$BACKUP_NAME"

# Set permissions
chmod 600 "$BACKUP_DIR/$BACKUP_NAME"

echo "✅ Backup created: $BACKUP_DIR/$BACKUP_NAME"

# Retention policy: keep 7 daily, 4 weekly, 12 monthly
echo "🧹 Applying retention policy..."

# Remove backups older than 1 year
find "$BACKUP_DIR" -name "fleetcommand_*.sql.gz" -mtime +365 -delete

# Keep only last 7 daily backups (but not weekly/monthly)
DAILY_BACKUPS=$(find "$BACKUP_DIR" -name "fleetcommand_*_*.sql.gz" -mtime -7 | wc -l)
if [ "$DAILY_BACKUPS" -gt 7 ]; then
    find "$BACKUP_DIR" -name "fleetcommand_*_*.sql.gz" -mtime -7 | head -n -$((DAILY_BACKUPS - 7)) | xargs rm -f
fi

# Keep only last 4 weekly backups (Sundays)
WEEKLY_BACKUPS=$(find "$BACKUP_DIR" -name "fleetcommand_*_*.sql.gz" -mtime -28 | xargs ls -t | grep -E ".*_(Sun|0).sql.gz" | wc -l)
if [ "$WEEKLY_BACKUPS" -gt 4 ]; then
    find "$BACKUP_DIR" -name "fleetcommand_*_*.sql.gz" -mtime -28 | xargs ls -t | grep -E ".*_(Sun|0).sql.gz" | tail -n +$((WEEKLY_BACKUPS - 4 + 1)) | xargs rm -f
fi

# Keep only last 12 monthly backups (1st of month)
MONTHLY_BACKUPS=$(find "$BACKUP_DIR" -name "fleetcommand_*_*.sql.gz" -mtime -365 | xargs ls -t | grep -E ".*_01_.*.sql.gz" | wc -l)
if [ "$MONTHLY_BACKUPS" -gt 12 ]; then
    find "$BACKUP_DIR" -name "fleetcommand_*_*.sql.gz" -mtime -365 | xargs ls -t | grep -E ".*_01_.*.sql.gz" | tail -n +$((MONTHLY_BACKUPS - 12 + 1)) | xargs rm -f
fi

echo "✅ Backup and cleanup complete!"

# Optional: Upload to offsite storage (S3-compatible)
# Uncomment and configure the following lines if you have S3 credentials
# if [ -n "$S3_BUCKET" ] && [ -n "$AWS_ACCESS_KEY_ID" ]; then
#     echo "☁️  Uploading to S3..."
#     aws s3 cp "$BACKUP_DIR/$BACKUP_NAME" "s3://$S3_BUCKET/backups/$BACKUP_NAME"
#     echo "✅ Uploaded to S3"
# fi

# Log backup completion
echo "$(date): Backup $BACKUP_NAME completed successfully" >> /opt/fleetcommand/logs/backup.log
