#!/bin/bash

set -e

echo "🚀 Bootstrapping AutoPredator FleetCommand Local Infrastructure"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker Desktop or Docker Engine."
    exit 1
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not available. Please ensure Docker Compose V2 is installed."
    exit 1
fi

# Copy .env.example to .env.local if it doesn't exist
if [ ! -f .env.local ]; then
    cp .env.example .env.local
    echo "✅ Copied .env.example to .env.local"
else
    echo "ℹ️  .env.local already exists, skipping copy"
fi

# Start Docker Compose services
echo "🐳 Starting Docker Compose services..."
docker compose -f infra/docker-compose.yml up -d

# Wait for services to be healthy
echo "⏳ Waiting for services to be healthy..."
docker compose -f infra/docker-compose.yml exec -T postgres pg_isready -U autopredator -d autopredator_dev
docker compose -f infra/docker-compose.yml exec -T redis redis-cli ping
echo "✅ Services are healthy"

# Install Python dependencies (assuming pip or poetry)
if [ -f "apps/api/requirements.txt" ]; then
    echo "📦 Installing Python dependencies..."
    pip install -r apps/api/requirements.txt
elif [ -f "apps/api/pyproject.toml" ]; then
    echo "📦 Installing Python dependencies with Poetry..."
    poetry install
else
    echo "⚠️  No requirements.txt or pyproject.toml found in apps/api/"
fi

# Install Node.js dependencies
if [ -f "apps/web/package.json" ]; then
    echo "📦 Installing Node.js dependencies for web..."
    cd apps/web && npm install && cd ../..
fi

if [ -f "frontend/package.json" ]; then
    echo "📦 Installing Node.js dependencies for frontend..."
    cd frontend && npm install && cd ..
fi

# Run database migrations
echo "🗄️  Running database migrations..."
cd apps/api
if [ -d "alembic" ]; then
    alembic upgrade head
else
    echo "⚠️  Alembic not configured yet"
fi
cd ../..

# Seed database
echo "🌱 Seeding database..."
cd apps/api
if [ -f "seed.py" ]; then
    python seed.py
else
    echo "⚠️  Seed script not found"
fi
cd ../..

echo "🎉 Bootstrap complete! Run './scripts/dev.sh' to start development servers."
