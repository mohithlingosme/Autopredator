#!/bin/bash
set -e

# Usage: ./deploy.sh <env> <tag>
# Example: ./deploy.sh staging v1.2.3

ENV=$1
TAG=$2

if [ -z "$ENV" ] || [ -z "$TAG" ]; then
    echo "Usage: $0 <env> <tag>"
    echo "Example: $0 staging v1.2.3"
    exit 1
fi

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "❌ .env file not found!"
    exit 1
fi

echo "🚀 Deploying $TAG to $ENV..."

# Set image tags
export API_IMAGE="${REGISTRY:-ghcr.io}/${GITHUB_REPOSITORY:-your-org/your-repo}:$TAG-api"
export WEB_IMAGE="${REGISTRY:-ghcr.io}/${GITHUB_REPOSITORY:-your-org/your-repo}:$TAG-web"
export WORKER_IMAGE="${REGISTRY:-ghcr.io}/${GITHUB_REPOSITORY:-your-org/your-repo}:$TAG-worker"

# Navigate to compose directory
cd infra/compose

# Pull latest images
echo "📦 Pulling latest images..."
docker-compose -f docker-compose.base.yml -f docker-compose.$ENV.yml pull

# Stop services gracefully
echo "🛑 Stopping current services..."
docker-compose -f docker-compose.base.yml -f docker-compose.$ENV.yml down --timeout 30

# Start services with new images
echo "▶️  Starting services with new images..."
docker-compose -f docker-compose.base.yml -f docker-compose.$ENV.yml up -d

# Wait for services to be healthy
echo "⏳ Waiting for services to be healthy..."
sleep 60

# Run health checks
echo "🏥 Running health checks..."
if curl -f -s https://api.${DOMAIN}/health > /dev/null 2>&1; then
    echo "✅ API health check passed"
else
    echo "❌ API health check failed"
    exit 1
fi

if curl -f -s https://app.${DOMAIN} > /dev/null 2>&1; then
    echo "✅ Web health check passed"
else
    echo "❌ Web health check failed"
    exit 1
fi

# Clean up old images
echo "🧹 Cleaning up old images..."
docker image prune -f

echo "✅ Deployment of $TAG to $ENV complete!"
