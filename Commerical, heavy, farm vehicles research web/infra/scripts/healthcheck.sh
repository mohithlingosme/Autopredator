#!/bin/bash

# Usage: ./healthcheck.sh <env>
# Example: ./healthcheck.sh staging

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

echo "🏥 Running health checks for $ENV environment..."

# Check Docker services
echo "🐳 Checking Docker services..."
SERVICES=$(docker-compose -f infra/compose/docker-compose.base.yml -f infra/compose/docker-compose.$ENV.yml ps --services --filter "status=running")

EXPECTED_SERVICES=("postgres" "redis" "api" "worker" "web" "caddy")
ALL_RUNNING=true

for service in "${EXPECTED_SERVICES[@]}"; do
    if echo "$SERVICES" | grep -q "^$service$"; then
        echo "✅ $service: running"
    else
        echo "❌ $service: not running"
        ALL_RUNNING=false
    fi
done

# Check API health
echo ""
echo "🔍 Checking API health..."
if curl -f -s https://api.${DOMAIN}/health > /dev/null 2>&1; then
    echo "✅ API /health: OK"
else
    echo "❌ API /health: FAILED"
    ALL_RUNNING=false
fi

# Check API readiness
if curl -f -s https://api.${DOMAIN}/ready > /dev/null 2>&1; then
    echo "✅ API /ready: OK"
else
    echo "❌ API /ready: FAILED"
    ALL_RUNNING=false
fi

# Check Web health
echo ""
echo "🌐 Checking Web health..."
if curl -f -s https://app.${DOMAIN} > /dev/null 2>&1; then
    echo "✅ Web: OK"
else
    echo "❌ Web: FAILED"
    ALL_RUNNING=false
fi

# Check database connectivity
echo ""
echo "🗄️  Checking database connectivity..."
if docker-compose -f infra/compose/docker-compose.base.yml -f infra/compose/docker-compose.$ENV.yml exec -T postgres pg_isready -U $DB_USER > /dev/null 2>&1; then
    echo "✅ Database: OK"
else
    echo "❌ Database: FAILED"
    ALL_RUNNING=false
fi

# Check Redis connectivity
echo ""
echo "🔴 Checking Redis connectivity..."
if docker-compose -f infra/compose/docker-compose.base.yml -f infra/compose/docker-compose.$ENV.yml exec -T redis redis-cli ping | grep -q "PONG"; then
    echo "✅ Redis: OK"
else
    echo "❌ Redis: FAILED"
    ALL_RUNNING=false
fi

# Check SSL certificate
echo ""
echo "🔒 Checking SSL certificate..."
CERT_INFO=$(echo | openssl s_client -servername app.${DOMAIN} -connect app.${DOMAIN}:443 2>/dev/null | openssl x509 -noout -dates 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "✅ SSL Certificate: OK"
    echo "   $CERT_INFO"
else
    echo "❌ SSL Certificate: FAILED"
    ALL_RUNNING=false
fi

echo ""
if [ "$ALL_RUNNING" = true ]; then
    echo "🎉 All health checks passed!"
    exit 0
else
    echo "💥 Some health checks failed!"
    exit 1
fi
