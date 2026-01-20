#!/bin/bash

set -e

echo "🔄 Resetting AutoPredator FleetCommand Local Infrastructure"

# Stop and remove containers
echo "🐳 Stopping and removing containers..."
docker compose -f infra/docker-compose.yml down

# Remove volumes (with warning)
echo "⚠️  This will remove all data in named volumes (Postgres, Redis, MinIO)."
read -p "Are you sure you want to remove volumes? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️  Removing volumes..."
    docker volume rm autopredatorfleetmanagement_postgres_data autopredatorfleetmanagement_redis_data autopredatorfleetmanagement_minio_data 2>/dev/null || true
    echo "✅ Volumes removed"
else
    echo "ℹ️  Volumes not removed"
fi

# Remove .env.local
if [ -f .env.local ]; then
    echo "🗑️  Removing .env.local..."
    rm .env.local
    echo "✅ .env.local removed"
fi

echo "🎉 Reset complete! Run ./scripts/bootstrap.sh to set up again."
