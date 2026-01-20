#!/bin/bash
set -e

# Usage: ./backup_postgres.sh <env>
# Example: ./backup_postgres.sh staging

ENV=$1

if [ -z "$ENV" ]; then
    echo "Usage: $0 <env>"
    echo "Example: $0 staging"
    exit 1
fi

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "❌ .env file not found!"
    exit 1
fi

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/opt/fleetcommand/backups"
BACKUP_FILE="$BACKUP_DIR/fleetcommand_${ENV}_${TIMESTAMP}.sql.gz"

echo "💾 Creating PostgreSQL backup for $ENV..."

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Create backup
docker-compose -f infra/compose/docker-compose.base.yml -f infra/compose/docker-compose.$ENV.yml exec -T postgres pg_dumpall -U $DB_USER | gzip > "$BACKUP_FILE"

# Set permissions
chmod 600 "$BACKUP_FILE"

# Calculate backup size
BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo "✅ Backup created: $BACKUP_FILE ($BACKUP_SIZE)"

# Clean up old backups (keep last 7 daily, 4 weekly, 12 monthly)
echo "🧹 Cleaning up old backups..."
cd "$BACKUP_DIR"

# Keep daily backups for 7 days
find . -name "fleetcommand_${ENV}_*.sql.gz" -mtime +7 -delete

# Keep weekly backups (Sundays) for 4 weeks
find . -name "fleetcommand_${ENV}_*_*_00.sql.gz" -mtime +28 -delete

# Keep monthly backups (1st of month) for 12 months
find . -name "fleetcommand_${ENV}_*01_*.sql.gz" -mtime +365 -delete

echo "✅ Backup cleanup complete"

# TODO: Upload to offsite storage (S3, GCS, etc.)
# Example:
# aws s3 cp "$BACKUP_FILE" "s3://your-backup-bucket/fleetcommand/$ENV/"

echo "📤 Upload to offsite storage: TODO - implement S3/GCS upload"
