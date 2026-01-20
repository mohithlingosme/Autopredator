#!/bin/bash
set -e

# Usage: ./rotate_secrets.sh <env>
# Example: ./rotate_secrets.sh staging

ENV=$1

if [ -z "$ENV" ]; then
    echo "Usage: $0 <env>"
    echo "Example: $0 staging"
    exit 1
fi

echo "🔄 Rotating secrets for $ENV environment..."

# Load current environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "❌ .env file not found!"
    exit 1
fi

# Generate new secrets
NEW_JWT_SECRET=$(openssl rand -hex 32)
NEW_DB_PASSWORD=$(openssl rand -hex 16)

echo "🔑 Generated new secrets"

# Update .env file
if [ -f ".env" ]; then
    # Update JWT secret
    sed -i.bak "s/^JWT_SECRET_KEY=.*/JWT_SECRET_KEY=$NEW_JWT_SECRET/" .env

    # Update DB password
    sed -i.bak "s/^DB_PASSWORD=.*/DB_PASSWORD=$NEW_DB_PASSWORD/" .env

    echo "✅ Updated .env file"
else
    echo "❌ .env file not found for updating"
    exit 1
fi

# Update database password in running containers
echo "🗄️  Updating database password..."
docker-compose -f infra/compose/docker-compose.base.yml -f infra/compose/docker-compose.$ENV.yml exec -T postgres psql -U $DB_USER -d postgres -c "ALTER USER $DB_USER PASSWORD '$NEW_DB_PASSWORD';"

echo "✅ Database password updated"

# Restart services to pick up new secrets
echo "🔄 Restarting services..."
docker-compose -f infra/compose/docker-compose.base.yml -f infra/compose/docker-compose.$ENV.yml restart api worker

echo "⏳ Waiting for services to restart..."
sleep 30

# Run health checks
echo "🏥 Running health checks..."
if curl -f -s https://api.${DOMAIN}/health > /dev/null 2>&1; then
    echo "✅ API health check passed"
else
    echo "❌ API health check failed - secrets rotation may have failed"
    exit 1
fi

if curl -f -s https://app.${DOMAIN} > /dev/null 2>&1; then
    echo "✅ Web health check passed"
else
    echo "❌ Web health check failed - secrets rotation may have failed"
    exit 1
fi

echo "✅ Secrets rotation for $ENV complete!"

# Backup the old .env file
cp .env.bak .env.backup.$(date +%Y%m%d_%H%M%S)
rm .env.bak

echo "📝 Old secrets backed up to .env.backup.*"
echo "⚠️  Remember to update any external systems (monitoring, etc.) with new secrets if needed"
