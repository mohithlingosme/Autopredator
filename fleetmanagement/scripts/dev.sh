#!/bin/bash

set -e

echo "🚀 Starting AutoPredator FleetCommand Development Environment"

# Check if Docker Compose is running
if ! docker compose -f infra/docker-compose.yml ps | grep -q "Up"; then
    echo "❌ Docker Compose services are not running. Run ./scripts/bootstrap.sh first."
    exit 1
fi

# Start API (FastAPI)
echo "🐍 Starting API server..."
cd apps/api
if [ -f "main.py" ]; then
    python main.py &
    API_PID=$!
    echo "✅ API started (PID: $API_PID)"
else
    echo "❌ API main.py not found"
    exit 1
fi
cd ../..

# Start Web (assuming Node.js/React)
echo "🌐 Starting Web server..."
cd apps/web
if [ -f "package.json" ]; then
    npm run dev &
    WEB_PID=$!
    echo "✅ Web started (PID: $WEB_PID)"
else
    echo "❌ Web package.json not found"
fi
cd ../..

# Start Worker (placeholder)
echo "⚙️  Starting Worker..."
cd apps/worker
# Placeholder: implement worker logic here
echo "✅ Worker placeholder started"
cd ../..

# Wait for interrupt
echo "🎉 Development servers started! Press Ctrl+C to stop."
trap "echo '🛑 Stopping servers...'; kill $API_PID $WEB_PID 2>/dev/null; exit" INT
wait
