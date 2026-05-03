#!/usr/bin/env python3
'''
Maruti Suzuki OEM Scraper (Tier 2)

https://www.marutisuzuki.com/cars → catalog → specs

Uses Playwright for JS rendering.
'''

from playwright.sync_api import sync_playwright
import json
import os
from datetime import datetime
from urllib.parse import urljoin
import re

OUTPUT_DIR = "../../scrape_output/maruti"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def scrape_maruti():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        
        page.goto("https://www.marutisuzuki.com/cars")
        
        # Extract car cards
        cars = page.query_selector_all('[data-car-model]')
        records = []
        
        for car in cars:
            model = car.get_attribute('data-model') or car.inner_text()
            href = car.get_attribute('href')
            
            rec = {
                'oem': 'Maruti Suzuki',
                'model': model,
                'url': urljoin('https://www.marutisuzuki.com', href),
                'scraped_at': datetime.now().isoformat(),
                'type': 'catalog'
            }
            records.append(rec)
        
        # Follow model pages for variants
        for rec in records[:5]:  # Limit
            page.goto(rec['url'])
            variants = page.query_selector_all('.variant-list li')
            rec['variants'] = [v.inner_text().strip() for v in variants]
        
        json.dump(records, open(os.path.join(OUTPUT_DIR, 'maruti_catalog.json'), 'w'), indent=2)
        print(f"Scraped {len(records)} Maruti models")
        
        browser.close()

if __name__ == '__main__':
    scrape_maruti()

