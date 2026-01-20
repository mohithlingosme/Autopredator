#!/usr/bin/env node

/**
 * Bootstrap script for FleetCommand local infrastructure.
 *
 * Sets up the complete local development environment.
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

function runCommand(command, description) {
  console.log(`🔧 ${description}...`);
  try {
    execSync(command, { stdio: 'inherit', cwd: process.cwd() });
    console.log(`✅ ${description} completed\n`);
  } catch (error) {
    console.error(`❌ ${description} failed:`, error.message);
    process.exit(1);
  }
}

function copyEnvFile(src, dest) {
  if (!fs.existsSync(dest)) {
    console.log(`📋 Copying ${src} to ${dest}...`);
    fs.copyFileSync(src, dest);
    console.log(`✅ Environment file created\n`);
  } else {
    console.log(`⚠️  ${dest} already exists, skipping\n`);
  }
}

function main() {
  console.log('🚀 FleetCommand Bootstrap\n');

  // Check if .env files exist, copy from examples if not
  const envFiles = [
    { example: 'apps/api/.env.example', target: 'apps/api/.env' },
    { example: 'apps/web/.env.example', target: 'apps/web/.env' },
    { example: 'apps/worker/.env.example', target: 'apps/worker/.env' }
  ];

  console.log('📋 Setting up environment files...\n');
  for (const { example, target } of envFiles) {
    if (fs.existsSync(example)) {
      copyEnvFile(example, target);
    } else {
      console.log(`⚠️  ${example} not found, skipping ${target}\n`);
    }
  }

  // Install dependencies
  runCommand('pnpm install', 'Installing dependencies');

  // Start Docker services
  runCommand('docker compose up -d postgres redis', 'Starting database and cache services');

  // Wait for services to be healthy
  console.log('⏳ Waiting for services to be healthy...');
  execSync('docker compose exec -T postgres pg_isready -U postgres', { stdio: 'pipe' });
  execSync('docker compose exec -T redis redis-cli ping', { stdio: 'pipe' });
  console.log('✅ Services are healthy\n');

  // Run database migrations
  runCommand('node scripts/db-migrate.js', 'Running database migrations');

  // Seed database
  runCommand('python scripts/seed.py', 'Seeding database with demo data');

  console.log('🎉 Bootstrap complete!\n');
  console.log('🌐 Services available at:');
  console.log('   Web:     http://localhost:3000');
  console.log('   API:     http://localhost:8000');
  console.log('   API Docs: http://localhost:8000/docs');
  console.log('\n👤 Demo credentials:');
  console.log('   Email: admin@demo.com');
  console.log('   Password: admin123');
  console.log('\n🔍 Check service health:');
  console.log('   curl http://localhost:8000/health');
  console.log('   curl http://localhost:8000/ready');
}

if (require.main === module) {
  main();
}
