#!/bin/bash
set -e

# Secret rotation script for AutoPredator FleetCommand
# This script helps rotate sensitive credentials

ENV=${1:-production}
CONFIG_DIR="/opt/fleetcommand/configs"

echo "🔐 Rotating secrets for $ENV environment..."

# Generate new JWT secret
NEW_JWT_SECRET=$(openssl rand -hex 32)
echo "New JWT Secret generated"

# Generate new DB password
NEW_DB_PASSWORD=$(openssl rand -hex 16)
echo "New DB password generated"

# Backup current .env
cp "$CONFIG_DIR/.env" "$CONFIG_DIR/.env.backup.$(date +%Y%m%d_%H%M%S)"
echo "✅ Current .env backed up"

# Update .env file
sed -i.bak "s/JWT_SECRET_KEY=.*/JWT_SECRET_KEY=$NEW_JWT_SECRET/" "$CONFIG_DIR/.env"
sed -i.bak "s/DB_PASSWORD=.*/DB_PASSWORD=$NEW_DB_PASSWORD/" "$CONFIG_DIR/.env"
echo "✅ .env file updated with new secrets"

# Update PostgreSQL password in running container
echo "🔄 Updating PostgreSQL password..."
docker exec fleetcommand_postgres_1 psql -U postgres -c "ALTER USER $DB_USER PASSWORD '$NEW_DB_PASSWORD';"
echo "✅ PostgreSQL password updated"

# Restart services to pick up new secrets
echo "🔄 Restarting services..."
cd "$CONFIG_DIR/infra/compose"
docker-compose -f docker-compose.base.yml -f docker-compose.$ENV.yml restart api worker

echo "⏳ Waiting for services to restart..."
sleep 30

# Run health checks
echo "🏥 Running health checks..."
if curl -f https://api.${DOMAIN}/health > /dev/null 2>&1; then
    echo "✅ API health check passed"
else
    echo "❌ API health check failed"
    echo "⚠️  You may need to update client applications with new secrets"
fi

echo "✅ Secret rotation complete!"
echo "📝 Important: Update any client applications or external services with the new JWT secret"
echo "📝 The old .env is backed up in $CONFIG_DIR/.env.backup.*"

# Log rotation
echo "$(date): Secrets rotated for $ENV" >> /opt/fleetcommand/logs/secrets.log
