# Testing Guide

This document explains how to run tests locally, set up the environment, and manage the database for testing.

## Environment Setup

1. Install PHP 8.2+ and Composer.
2. Install dependencies: `composer install`
3. Set up the database: Use the provided `docker-compose.yml` or set up MySQL/PostgreSQL locally.
4. Copy `config.php` and adjust database settings for testing.

## Database Setup

For tests, use a separate test database. Run migrations and seed data:

- `php scripts/seed.php` (adjust for test DB)

## Running Tests

- All tests: `composer test`
- Unit tests: `composer test:unit`
- Integration tests: `composer test:integration`
- E2E tests: `composer test:e2e`

## Other Commands

- Lint: `composer lint`
- Format: `composer format`
- Typecheck: `composer typecheck`
- Build: `composer build` (if applicable)
- Seed test DB: `composer seed:testdb`
