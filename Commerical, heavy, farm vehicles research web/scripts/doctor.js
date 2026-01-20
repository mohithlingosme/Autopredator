#!/usr/bin/env node

/**
 * Doctor script for FleetCommand local infrastructure.
 *
 * Verifies that all required tools are installed and configured correctly.
 */

const { execSync } = require('child_process');

const REQUIREMENTS = [
  {
    name: 'Git',
    command: 'git --version',
    pattern: /git version (\d+\.\d+\.\d+)/,
    minVersion: null,
    required: true
  },
  {
    name: 'Node.js',
    command: 'node --version',
    pattern: /v(\d+\.\d+\.\d+)/,
    minVersion: '18.0.0',
    required: true
  },
  {
    name: 'pnpm',
    command: 'pnpm --version',
    pattern: /(\d+\.\d+\.\d+)/,
    minVersion: '8.0.0',
    required: true
  },
  {
    name: 'Python',
    command: 'python --version',
    pattern: /Python (\d+\.\d+\.\d+)/,
    minVersion: '3.11.0',
    required: true
  },
  {
    name: 'Docker',
    command: 'docker --version',
    pattern: /Docker version (\d+\.\d+\.\d+)/,
    minVersion: null,
    required: true
  },
  {
    name: 'Docker Compose',
    command: 'docker compose version',
    pattern: /Docker Compose version v?(\d+\.\d+\.\d+)/,
    minVersion: null,
    required: true,
    fallbackCommand: 'docker-compose --version',
    fallbackPattern: /docker-compose version (\d+\.\d+\.\d+)/
  }
];

function parseVersion(versionString) {
  return versionString.split('.').map(Number);
}

function compareVersions(a, b) {
  const aParts = parseVersion(a);
  const bParts = parseVersion(b);

  for (let i = 0; i < Math.max(aParts.length, bParts.length); i++) {
    const aPart = aParts[i] || 0;
    const bPart = bParts[i] || 0;

    if (aPart > bPart) return 1;
    if (aPart < bPart) return -1;
  }

  return 0;
}

function checkRequirement(req) {
  try {
    let output;
    try {
      output = execSync(req.command, { encoding: 'utf8', stdio: 'pipe' });
    } catch (e) {
      // Try fallback command if available
      if (req.fallbackCommand) {
        output = execSync(req.fallbackCommand, { encoding: 'utf8', stdio: 'pipe' });
      } else {
        throw e;
      }
    }

    const match = output.match(req.pattern) || (req.fallbackPattern && output.match(req.fallbackPattern));
    if (!match) {
      return { status: 'error', message: `Could not parse version from output: ${output.trim()}` };
    }

    const version = match[1];

    if (req.minVersion && compareVersions(version, req.minVersion) < 0) {
      return { status: 'error', message: `Version ${version} is below minimum required ${req.minVersion}` };
    }

    return { status: 'ok', version };
  } catch (error) {
    if (req.required) {
      return { status: 'error', message: `Not installed or not in PATH` };
    } else {
      return { status: 'warning', message: `Not installed (optional)` };
    }
  }
}

function printResult(name, result) {
  const icons = {
    ok: '✅',
    warning: '⚠️ ',
    error: '❌'
  };

  const colors = {
    ok: '\x1b[32m',
    warning: '\x1b[33m',
    error: '\x1b[31m',
    reset: '\x1b[0m'
  };

  console.log(`${icons[result.status]} ${name}: ${colors[result.status]}${result.message}${colors.reset}`);
}

function main() {
  console.log('🏥 FleetCommand Doctor\n');
  console.log('Checking system requirements...\n');

  let allOk = true;
  let hasErrors = false;

  for (const req of REQUIREMENTS) {
    const result = checkRequirement(req);
    printResult(req.name, result);

    if (result.status === 'error') {
      hasErrors = true;
      if (req.required) {
        allOk = false;
      }
    }
  }

  console.log('\n' + '='.repeat(50));

  if (allOk) {
    console.log('🎉 All required tools are properly installed!');
    console.log('\nNext steps:');
    console.log('   pnpm bootstrap  # Set up the development environment');
  } else {
    console.log('❌ Some required tools are missing or outdated.');
    console.log('\nPlease install/update the missing tools and run this script again.');
    console.log('\nFor installation instructions, see: docs/Local_Infrastructure.md');
    process.exit(1);
  }

  if (hasErrors) {
    console.log('\n⚠️  Some optional tools are missing. While not required, they are recommended for development.');
  }
}

if (require.main === module) {
  main();
}
