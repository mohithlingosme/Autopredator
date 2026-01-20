#!/bin/bash

# Autopredator DB Reset Script (Unix)
# Resets the local database services (removes data)

set -e

echo "⚠️  This will remove all database data!"
read -p "Are you sure? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo "🔄 Resetting database services..."

if [ ! -f docker-compose.yml ]; then
    echo "Error: docker-compose.yml not found in root directory"
    exit 1
fi

docker-compose down -v

echo "🗑️  Database data removed."
echo "🚀 Run 'scripts/db-up.sh' to restart services."
