#!/bin/bash
set -e

# Usage: ./restore_postgres.sh <env> <backup_file>
# Example: ./restore_postgres.sh staging /opt/fleetcommand/backups/fleetcommand_staging_20231201_120000.sql.gz

ENV=$1
BACKUP_FILE=$2

if [ -z "$ENV" ] || [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <env> <backup_file>"
    echo "Example: $0 staging /opt/fleetcommand/backups/fleetcommand_staging_20231201_120000.sql.gz"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Backup file not found: $BACKUP_FILE"
    exit 1
fi

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "❌ .env file not found!"
    exit 1
fi

echo "⚠️  WARNING: This will REPLACE the current database!"
read -p "Are you sure you want to restore from $BACKUP_FILE? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Restore cancelled"
    exit 1
fi

echo "🔄 Restoring PostgreSQL database for $ENV from $BACKUP_FILE..."

# Stop services that depend on database
echo "🛑 Stopping services..."
docker-compose -f infra/compose/docker-compose.base.yml -f infra/compose/docker-compose.$ENV.yml stop api worker web

# Restore database
echo "📦 Restoring database..."
gunzip -c "$BACKUP_FILE" | docker-compose -f infra/compose/docker-compose.base.yml -f infra/compose/docker-compose.$ENV.yml exec -T postgres psql -U $DB_USER -d postgres

# Start services back up
echo "▶️  Starting services..."
docker-compose -f infra/compose/docker-compose.base.yml -f infra/compose/docker-compose.$ENV.yml start api worker web

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 30

# Run health checks
echo "🏥 Running health checks..."
if curl -f https://api.${DOMAIN}/health > /dev/null 2>&1; then
    echo "✅ API health check passed"
else
    echo "❌ API health check failed"
    exit 1
fi

if curl -f https://app.${DOMAIN} > /dev/null 2>&1; then
    echo "✅ Web health check passed"
else
    echo "❌ Web health check failed"
    exit 1
fi

echo "✅ Database restore for $ENV complete!"
echo "📝 Note: You may need to run database migrations if the backup is from an older version."
