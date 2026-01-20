#!/bin/bash

set -e

echo "🧪 Running AutoPredator FleetCommand Smoke Tests"

# Check if Docker Compose is running
if ! docker compose -f infra/docker-compose.yml ps | grep -q "Up"; then
    echo "❌ Docker Compose services are not running. Run ./scripts/bootstrap.sh first."
    exit 1
fi

# Check Postgres
echo "🔍 Checking Postgres..."
if docker compose -f infra/docker-compose.yml exec -T postgres pg_isready -U autopredator -d autopredator_dev; then
    echo "✅ Postgres is reachable"
else
    echo "❌ Postgres is not reachable"
    exit 1
fi

# Check Redis
echo "🔍 Checking Redis..."
if docker compose -f infra/docker-compose.yml exec -T redis redis-cli ping | grep -q "PONG"; then
    echo "✅ Redis is reachable"
else
    echo "❌ Redis is not reachable"
    exit 1
fi

# Check Mailpit
echo "🔍 Checking Mailpit..."
if curl -f -s http://localhost:8025 > /dev/null; then
    echo "✅ Mailpit is reachable"
else
    echo "❌ Mailpit is not reachable"
    exit 1
fi

# Check API health
echo "🔍 Checking API health..."
if curl -f -s http://localhost:8000/health | grep -q '"status":"healthy"'; then
    echo "✅ API is healthy"
else
    echo "❌ API is not healthy"
    exit 1
fi

# Optional: Check web if running
if curl -f -s http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ Web is reachable"
else
    echo "⚠️  Web is not reachable (may not be started)"
fi

echo "🎉 All smoke tests passed!"
