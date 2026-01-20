#!/bin/bash

# Autopredator Monorepo Bootstrap Script (Unix)
# Installs dependencies across the monorepo

set -e

echo "📦 Bootstrapping monorepo..."

# Install root dependencies
if [ -f package.json ]; then
    npm install
fi

# Install web app dependencies
if [ -d "apps/web" ] && [ -f "apps/web/package.json" ]; then
    echo "Installing web app dependencies..."
    cd apps/web
    npm install
    cd ../..
fi

# Install API dependencies
if [ -d "apps/api" ] && [ -f "apps/api/requirements.txt" ]; then
    echo "Installing API dependencies..."
    cd apps/api
    pip install -r requirements.txt
    if [ -f "requirements-dev.txt" ]; then
        pip install -r requirements-dev.txt
    fi
    cd ../..
fi

# Install workers dependencies (if exists)
if [ -d "apps/workers" ] && [ -f "apps/workers/requirements.txt" ]; then
    echo "Installing workers dependencies..."
    cd apps/workers
    pip install -r requirements.txt
    cd ../..
fi

# Install shared packages (if exists)
if [ -d "packages/shared" ] && [ -f "packages/shared/package.json" ]; then
    echo "Installing shared packages..."
    cd packages/shared
    npm install
    cd ../..
fi

echo "✅ Bootstrap complete!"
