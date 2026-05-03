#!/usr/bin/env python3
"""
Single Script to Run + Test All Autopredator Scrapers

Usage: python run_scrapers.py --limited --etl

Tests tier1-4, generates JSONL, optional ETL import.
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path
import json
import time

SCRP_DIR = Path('autopredator/scrapers')
OUTPUT_DIR = Path('scrape_output')
OUTPUT_DIR.mkdir(exist_ok=True)

SCRAPERS = {
    'tier1_siam': 'tier1_gov/siam_pdf_parser.py',
    'tier1_vahan': 'tier1_gov/vahan_selenium.py', 
    'tier2_maruti': 'tier2_oem/maruti_scraper.py',
    'tier3_market': 'tier3_marketplace/general_scraper.py',
}

def run_scraper(name: str, limited: bool = True):
    script = SCRP_DIR / SCRAPERS[name]
    if not script.exists():
        print(f"❌ {name} missing: {script}")
        return False

    cmd = [sys.executable, str(script)]
    if limited:
        cmd += ['--max-pages', '3']  # Limit for test
    if proxy_url:
        cmd += ['--proxy-url', proxy_url]

    print(f"🕷️  Running {name}...")
    try:
        result = subprocess.run(cmd, cwd=str(SCRP_DIR), 
                               capture_output=True, text=True, timeout=300)
        print(f"✅ {name} OK: {result.returncode == 0}")
        print(result.stdout[:200] + '...' if result.stdout else '')
        return result.returncode == 0
    except Exception as e:
        print(f"❌ {name} failed: {e}")
        return False

def verify_jsonl(path: Path):
    if path.exists() and path.stat().st_size > 100:
        with open(path, encoding='utf-8') as f:
            lines = [json.loads(line.strip()) for line in f.readlines()[:5]]
        print(f"✅ {path.name}: {len(lines)} valid records")
        return True
    return False

def test_etl(jsonl_path: Path):
    php_script = Path('autopredator/scraper/scripts/import_json_to_db.php')
    cmd = ['php', str(php_script), '--file', str(jsonl_path), '--type', 'siam']
    print("📊 Testing ETL...")
    subprocess.run(cmd)
    print("✅ ETL test complete")

if __name__ == '__main__':
    import random  # Move up for global scope
    parser = argparse.ArgumentParser()
    parser.add_argument('--limited', action='store_true', default=True)
    parser.add_argument('--etl', action='store_true')
    parser.add_argument('--proxy', action='store_true')
    args = parser.parse_args()

    proxy_url = None
    if args.proxy:
        proxy_file = SCRP_DIR / 'proxies.txt'
        with open(proxy_file, encoding='utf-8') as f:
            proxies = [l.strip() for l in f if l.strip() and not l.startswith('#')]
        if proxies:
            proxy_url = random.choice(proxies)
            print(f"🛡️ Using proxy: {proxy_url}")
        else:
            print("⚠️ No proxies found")

    success = 0
    for name in SCRAPERS:
        if run_scraper(name, args.limited):
            success += 1
        time.sleep(2)

    print(f"\n🎉 Summary: {success}/{len(SCRAPERS)} scrapers OK")

    # Verify outputs
    jsonl_files = OUTPUT_DIR.glob('*.jsonl')
    for f in jsonl_files:
        verify_jsonl(f)

    if args.etl:
        test_etl(OUTPUT_DIR / 'siam_sales.jsonl')

    sys.exit(0 if success == len(SCRAPERS) else 1)

