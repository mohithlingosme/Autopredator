import { test, expect } from '@playwright/test';

test('search and compare cars', async ({ page }) => {
  await page.goto('/');
  await page.fill('input[name="query"]', 'SUV');
  await page.click('button[type="submit"]');
  await expect(page.locator('.car-card')).toHaveCountGreaterThan(0);
  await page.check('input[type="checkbox"][value="1"]');
  await page.check('input[type="checkbox"][value="2"]');
  await page.click('button:has-text("Compare")');
  await expect(page).toHaveURL(/\/compare\.php/);
  await expect(page.locator('.comparison-table')).toBeVisible();
});
