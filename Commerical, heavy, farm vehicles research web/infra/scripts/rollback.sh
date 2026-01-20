#!/bin/bash
set -e

# Usage: ./rollback.sh <env> <previous_tag>
# Example: ./rollback.sh staging v1.2.2

ENV=$1
PREVIOUS_TAG=$2

if [ -z "$ENV" ] || [ -z "$PREVIOUS_TAG" ]; then
    echo "Usage: $0 <env> <previous_tag>"
    echo "Example: $0 staging v1.2.2"
    exit 1
fi

echo "🔄 Rolling back $ENV to tag $PREVIOUS_TAG..."

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "❌ .env file not found!"
    exit 1
fi

# Set image tags to previous version
export API_IMAGE="your-registry/fleetcommand-api:$PREVIOUS_TAG"
export WEB_IMAGE="your-registry/fleetcommand-web:$PREVIOUS_TAG"
export WORKER_IMAGE="your-registry/fleetcommand-worker:$PREVIOUS_TAG"

# Navigate to compose directory
cd infra/compose

# Stop current services
echo "🛑 Stopping current services..."
docker-compose -f docker-compose.base.yml -f docker-compose.$ENV.yml down --timeout 30

# Start services with previous images
echo "▶️  Starting services with previous images..."
docker-compose -f docker-compose.base.yml -f docker-compose.$ENV.yml up -d

# Wait for health checks
echo "⏳ Waiting for services to be healthy..."
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

echo "✅ Rollback to $ENV complete!"
