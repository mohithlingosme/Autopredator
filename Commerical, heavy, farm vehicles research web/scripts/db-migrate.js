#!/usr/bin/env node

/**
 * Database migration script for FleetCommand.
 *
 * Runs Alembic migrations for the API service.
 */

const { execSync } = require('child_process');
const path = require('path');

function runCommand(command, description, cwd = null) {
  console.log(`🔧 ${description}...`);
  try {
    const options = { stdio: 'inherit' };
    if (cwd) options.cwd = cwd;
    execSync(command, options);
    console.log(`✅ ${description} completed\n`);
  } catch (error) {
    console.error(`❌ ${description} failed:`, error.message);
    process.exit(1);
  }
}

function main() {
  console.log('🗃️  FleetCommand Database Migration\n');

  const apiDir = path.join(process.cwd(), 'apps', 'api');

  // Check if we're running in container or host
  let inContainer = false;
  try {
    execSync('docker compose ps | grep -q api', { stdio: 'pipe' });
    inContainer = true;
  } catch (e) {
    // Not in container, run on host
  }

  if (inContainer) {
    // Run migration in the running API container
    runCommand('docker compose exec api alembic upgrade head', 'Running migrations in container');
  } else {
    // Run migration on host (requires Python environment)
    console.log('📍 Running migrations on host...\n');

    // Ensure we're in the API directory
    process.chdir(apiDir);

    // Run alembic migration
    runCommand('alembic upgrade head', 'Running Alembic migrations', apiDir);
  }

  console.log('🎉 Database migration complete!');
}

if (require.main === module) {
  main();
}
