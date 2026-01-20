# Autopredator Monorepo Check Script (Windows)
# Runs linting, formatting, and type checking across all apps

param()

Write-Host "🔍 Running checks across the monorepo..." -ForegroundColor Green

# Run the Node check script
node scripts/check.js
