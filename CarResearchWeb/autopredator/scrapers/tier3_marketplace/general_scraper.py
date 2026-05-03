#!/usr/bin/env python3
"""
Enhanced Autopredator Marketplace Scraper with Proxy Rotation

Tier 3: CarDekho, CarWale, ZigWheels

Key enhancements:
- Proxy rotation from proxies.txt
- Session refresh every 50 requests
- Better error handling
- Configurable domains/limits

Install:
  pip install requests beautifulsoup4 lxml pypdf pymysql playwright

Usage:
  python general_scraper.py --domains cardekho --max-pages 100
"""

from __future__ import annotations

import argparse
import hashlib
import io
import json
import os
import random
import re
import sys
import time
from collections import defaultdict, deque
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional, Set, Tuple
from urllib.parse import urljoin, urlparse, urlunparse
from urllib.robotparser import RobotFileParser
from xml.etree import ElementTree as ET

import requests
from bs4 import BeautifulSoup

try:
    from pypdf import PdfReader
except Exception:
    PdfReader = None

try:
    import pymysql
except Exception:
    pymysql = None


# =============================================================================
# ENHANCED CONFIG WITH PROXIES
# =============================================================================

PROXY_FILE = "../proxies.txt"
START_URLS = [
    "https://www.cardekho.com/newcars",
    "https://www.carwale.com/new-cars/",
    "https://www.zigwheels.com/newcars",
]

DOMAINS = {
    "cardekho.com",
    "carwale.com", 
    "zigwheels.com",
}

OUTPUT_DIR = "../../scrape_output"
JSONL_PATH = os.path.join(OUTPUT_DIR, "raw_marketplace_pages.jsonl")
ERRORS_PATH = os.path.join(OUTPUT_DIR, "scrape_errors.jsonl")
SUMMARY_PATH = os.path.join(OUTPUT_DIR, "scrape_summary.json")

MAX_DEPTH = 4
MAX_PAGES_PER_DOMAIN = 2000
REQUEST_TIMEOUT = 25
RATE_LIMIT_SECONDS = 2.0
PROXY_ROTATE_EVERY = 50  # requests per proxy
USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36...",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWeb...",
    # Add 10+ more realistic UAs
]

ENABLE_MYSQL = False
# ... (rest of MYSQL_CONFIG same as original)

# Proxy config
USE_PROXIES = True
PROXY_FAIL_RETRY = 3


# =============================================================================
# PROXY MANAGER (NEW)
# =============================================================================

class ProxyManager:
    def __init__(self, proxy_file: str):
        self.proxies = self.load_proxies(proxy_file)
        self.current_index = 0
        self.request_count = 0
        self.failed_proxies = set()
    
    def load_proxies(self, path: str) -> List[str]:
        """Load proxies from file, filter comments/empty."""
        if not os.path.exists(path):
            print(f"Warning: {path} not found. Running without proxies.")
            return []
        
        proxies = []
        with open(path, "r") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#"):
                    proxies.append(line)
        print(f"Loaded {len(proxies)} proxies")
        return proxies
    
    def get_proxy(self) -> Optional[str]:
        """Get next proxy, rotate every PROXY_ROTATE_EVERY requests."""
        if not self.proxies or not USE_PROXIES:
            return None
        
        # Remove failed proxies temporarily
        available = [p for p in self.proxies if p not in self.failed_proxies]
        if not available:
            print("All proxies failed, fallback no-proxy")
            return None
        
        if self.request_count % PROXY_ROTATE_EVERY == 0:
            self.current_index = random.randint(0, len(available) - 1)
        
        proxy = available[self.current_index]
        self.request_count += 1
        return {"http": proxy, "https": proxy}
    
    def mark_failed(self, proxy: str):
        """Mark proxy failed for this run."""
        self.failed_proxies.add(proxy)
        print(f"Marked proxy failed: {proxy}")


proxy_mgr = ProxyManager(PROXY_FILE)


# =============================================================================
# DATA MODELS (UNCHANGED)
# =============================================================================
@dataclass
class ScrapeRecord:
    # ... (exact same as original scraper.py)

@dataclass
class VehicleCandidate:
    # ... (exact same)

# =============================================================================
# UTILITIES (ENHANCED SESSION)
# =============================================================================

def make_session() -> requests.Session:
    s = requests.Session()
    s.headers.update({
        "User-Agent": random.choice(USER_AGENTS),
        "Accept": "text/html,application/xhtml+xml;q=0.9,*/*;q=0.8",
        "Accept-Language": "en-IN,en;q=0.9,en-US;q=0.7",
    })
    return s

def fetch_with_proxy(session: requests.Session, url: str, proxy: Optional[Dict[str,str]] = None, retries: int = 3) -> Tuple[Optional[requests.Response], Optional[str]]:
    """Enhanced fetch with proxy + failure handling."""
    last_proxy = proxy
    for attempt in range(retries):
        try:
            resp = session.get(url, timeout=REQUEST_TIMEOUT, proxies=proxy, allow_redirects=True)
            return resp, None
        except Exception as e:
            error = str(e)
            print(f"Fetch failed (attempt {attempt+1}): {error}")
            if proxy and "proxy" in error.lower():
                proxy_mgr.mark_failed(list(proxy.values())[0])
                proxy = proxy_mgr.get_proxy()
            time.sleep(min(2 ** attempt * 1.5, 10))
    return None, f"Failed after {retries} retries. Last proxy: {last_proxy}"

# =============================================================================
# CRAWLER (PROXY INTEGRATED)
# =============================================================================

def crawl(args: argparse.Namespace) -> None:
    ensure_output_dir()
    
    session = make_session()
    robots = RobotsCache()
    
    # Proxy-enabled frontier logic...
    # (Full crawler logic with fetch_with_proxy(session, url, proxy_mgr.get_proxy()))
    
    # Use proxy_mgr.get_proxy() in main loop
    # Refresh session every 50 requests to rotate UA/proxy
    
    # ... (rest integrates proxy_mgr.get_proxy() into fetch calls)
    
    # Stats include proxy usage stats

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Enhanced Marketplace Scraper")
    parser.add_argument("--domains", nargs="*", help="Limit domains")
    parser.add_argument("--max-pages", type=int, default=MAX_PAGES_PER_DOMAIN)
    args = parser.parse_args()
    crawl(args)

