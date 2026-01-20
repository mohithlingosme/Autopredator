#!/usr/bin/env node

/**
 * Reset script for FleetCommand local infrastructure.
 *
 * Stops services, removes volumes, and rebuilds the environment.
 */

const { execSync } = require('child_process');
const readline = require('readline');

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

function askConfirmation(question) {
  return new Promise((resolve) => {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });

    rl.question(question, (answer) => {
      rl.close();
      resolve(answer.toLowerCase() === 'y' || answer.toLowerCase() === 'yes');
    });
  });
}

async function main() {
  console.log('🔄 FleetCommand Environment Reset\n');
  console.log('⚠️  This will stop all services and remove all data volumes!\n');

  const confirmed = await askConfirmation('Are you sure you want to continue? (y/N): ');

  if (!confirmed) {
    console.log('❌ Reset cancelled.');
    process.exit(0);
  }

  // Stop all services
  runCommand('docker compose down', 'Stopping all services');

  // Remove volumes (this deletes all data)
  runCommand('docker compose down -v', 'Removing data volumes');

  // Rebuild and restart services
  runCommand('docker compose up -d --build', 'Rebuilding and starting services');

  // Wait for services to be healthy
  console.log('⏳ Waiting for services to be healthy...');
  execSync('docker compose exec -T postgres pg_isready -U postgres', { stdio: 'pipe' });
  execSync('docker compose exec -T redis redis-cli ping', { stdio: 'pipe' });
  console.log('✅ Services are healthy\n');

  // Run migrations
  runCommand('node scripts/db-migrate.js', 'Running database migrations');

  console.log('🎉 Environment reset complete!');
  console.log('💡 Run "pnpm seed" to populate with demo data.');
}

if (require.main === module) {
  main();
}
