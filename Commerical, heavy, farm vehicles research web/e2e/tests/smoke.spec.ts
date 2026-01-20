import { test, expect } from '@playwright/test';

/**
 * Smoke tests for FleetCommand application.
 *
 * These tests verify basic functionality and ensure the application
 * is working correctly after deployment or major changes.
 */

test.describe('Smoke Tests', () => {
  test('should load the login page', async ({ page }) => {
    // Navigate to the application
    await page.goto('/');

    // Check that the page loaded
    await expect(page).toHaveTitle(/FleetCommand/);

    // Check for login form elements
    await expect(page.locator('input[type="email"]')).toBeVisible();
    await expect(page.locator('input[type="password"]')).toBeVisible();
    await expect(page.locator('button[type="submit"]')).toBeVisible();
  });

  test('should have working health check endpoint', async ({ page }) => {
    // Navigate to health check endpoint
    const response = await page.request.get('http://localhost:8000/health');

    // Check response
    expect(response.status()).toBe(200);
    const data = await response.json();
    expect(data.status).toBe('healthy');
    expect(data.service).toBe('fleetcommand-api');
  });

  test('should have working readiness check endpoint', async ({ page }) => {
    // Navigate to readiness check endpoint
    const response = await page.request.get('http://localhost:8000/ready');

    // Check response
    expect(response.status()).toBe(200);
    const data = await response.json();
    expect(data.service).toBe('fleetcommand-api');
    expect(['ready', 'not ready']).toContain(data.status);
  });

  test('should serve API documentation', async ({ page }) => {
    // Navigate to API docs
    await page.goto('http://localhost:8000/docs');

    // Check that docs loaded
    await expect(page.locator('text=FleetCommand API')).toBeVisible();
  });
});
