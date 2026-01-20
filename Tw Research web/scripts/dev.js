#!/usr/bin/env node

const { spawn } = require('child_process');
const concurrently = require('concurrently');

console.log('🚀 Starting development environment...');

const commands = [];

// Start database if docker-compose exists
if (require('fs').existsSync('docker-compose.yml')) {
  commands.push({
    command: 'docker-compose up',
    name: 'db',
    prefixColor: 'blue'
  });
}

// Start API if it exists
if (require('fs').existsSync('apps/api')) {
  commands.push({
    command: 'cd apps/api && python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000',
    name: 'api',
    prefixColor: 'green'
  });
}

// Start web app if it exists
if (require('fs').existsSync('apps/web')) {
  commands.push({
    command: 'cd apps/web && npm run dev',
    name: 'web',
    prefixColor: 'yellow'
  });
}

// Start workers if they exist
if (require('fs').existsSync('apps/workers')) {
  commands.push({
    command: 'cd apps/workers && python worker.py',
    name: 'worker',
    prefixColor: 'magenta'
  });
}

if (commands.length === 0) {
  console.log('No services to start. Check if apps directories exist.');
  process.exit(0);
}

concurrently(commands, {
  prefix: 'name',
  killOthers: ['failure', 'success'],
}).then(() => {
  console.log('✅ All services stopped.');
}, (error) => {
  console.error('❌ Error starting services:', error);
  process.exit(1);
});
