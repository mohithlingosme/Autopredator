#!/usr/bin/env node

/**
 * Database reset script for FleetCommand.
 *
 * Drops and recreates the database schema, then runs migrations.
 * WARNING: This will delete all data!
 */

const { runCommand } = require('./bootstrap');

async function dbReset() {
  console.log('🔄 Resetting database...');

  try {
    // Drop and recreate schema
    console.log('📉 Dropping existing schema...');
    await runCommand('docker-compose exec -T postgres psql -U postgres -d postgres -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"', {
      cwd: process.cwd()
    });

    // Run migrations
    console.log('📈 Running migrations...');
    await runCommand('docker-compose exec -T api alembic upgrade head', {
      cwd: process.cwd()
    });

    console.log('✅ Database reset complete!');
    console.log('💡 Run "pnpm seed" to populate with demo data.');

  } catch (error) {
    console.error('❌ Database reset failed:', error.message);
    process.exit(1);
  }
}

if (require.main === module) {
  dbReset();
}

module.exports = { dbReset };
