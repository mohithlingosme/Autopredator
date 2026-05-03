#!/usr/bin/env python3
"""
autopredator_india_scraper.py

Indian-context automotive scraper for:
- new cars
- compare pages
- news/reviews pages
- used car pages
- official/registry public pages (where allowed)
- PDFs / brochures
- JSON-LD extraction
- staging into MariaDB/MySQL

Designed for public, permitted sources only.
Respects robots.txt by default.

Install:
  pip install requests beautifulsoup4 lxml pypdf pymysql

Optional browser rendering:
  pip install playwright
  playwright install
"""

from __future__ import annotations

import hashlib
import io
import json
import os
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
# CONFIG
# =============================================================================

START_URLS = [
    # Indian automotive portals
    "https://www.cardekho.com/newcars",
    "https://www.cardekho.com/compare-cars",
    "https://www.cardekho.com/latestcars",
    "https://www.carwale.com/new-cars/",
    "https://www.carwale.com/compare-cars/",
    "https://www.carwale.com/news/",
    "https://www.zigwheels.com/",
    "https://www.zigwheels.com/compare-cars",
    "https://www.zigwheels.com/apps",

    # Public vehicle registry / government sources
    "https://vahan.parivahan.gov.in/paidnrservices/",
    "https://analytics.parivahan.gov.in/",
    "https://parivahan.gov.in/",
]

ALLOWED_DOMAINS = {
    "cardekho.com",
    "carwale.com",
    "zigwheels.com",
    "vahan.parivahan.gov.in",
    "analytics.parivahan.gov.in",
    "parivahan.gov.in",
}

OUTPUT_DIR = "scrape_output"
JSONL_PATH = os.path.join(OUTPUT_DIR, "raw_indian_vehicle_pages.jsonl")
ERRORS_PATH = os.path.join(OUTPUT_DIR, "scrape_errors.jsonl")
SUMMARY_PATH = os.path.join(OUTPUT_DIR, "scrape_summary.json")

MAX_DEPTH = 6
MAX_PAGES_PER_DOMAIN = 5000
REQUEST_TIMEOUT = 30
RATE_LIMIT_SECONDS = 1.2
USER_AGENT = "AutopredatorIndiaBot/1.0 (+contact: you@example.com)"
RESPECT_ROBOTS = True
STRICT_DOMAIN_LOCK = True

ENABLE_MYSQL = False
MYSQL_CONFIG = {
    "host": "127.0.0.1",
    "user": "root",
    "password": "",
    "database": "autopredator_cars",
    "charset": "utf8mb4",
}

PDF_CONTENT_TYPES = {"application/pdf"}
HTML_CONTENT_TYPES = {"text/html", "application/xhtml+xml"}

INDIAN_PRICE_RE = re.compile(
    r"(₹\s?[\d,]+(?:\.\d+)?\s?(?:Lakh|Crore|K)?|INR\s?[\d,]+(?:\.\d+)?)",
    re.I,
)
MILEAGE_RE = re.compile(r"(\d+(?:\.\d+)?)\s?(kmpl|km/l|km per litre|km/litre|kmpl\.)", re.I)
POWER_RE = re.compile(r"(\d+(?:\.\d+)?)\s?(bhp|hp|kw|ps)\b", re.I)
TORQUE_RE = re.compile(r"(\d+(?:\.\d+)?)\s?(nm|n.m|newton meters?)\b", re.I)
ENGINE_CC_RE = re.compile(r"(\d{3,4})\s?cc\b", re.I)
SEATING_RE = re.compile(r"(\d)\s?-?\s?(seater|seats?)\b", re.I)
BATTERY_RE = re.compile(r"(\d+(?:\.\d+)?)\s?kwh\b", re.I)
RANGE_RE = re.compile(r"(\d+(?:\.\d+)?)\s?(km|kms)\b", re.I)


# =============================================================================
# DATA MODELS
# =============================================================================

@dataclass
class ScrapeRecord:
    source_url: str
    final_url: str
    url_hash: str
    fetched_at: str
    content_type: str
    status_code: int
    domain: str
    page_depth: int
    title: Optional[str] = None
    meta_description: Optional[str] = None
    canonical_url: Optional[str] = None
    h1: Optional[str] = None
    text_content: Optional[str] = None
    extracted_tables: Optional[List[List[List[str]]]] = None
    links: Optional[List[str]] = None
    image_urls: Optional[List[str]] = None
    raw_jsonld: Optional[List[Dict[str, Any]]] = None
    pdf_text: Optional[str] = None
    content_hash: Optional[str] = None


@dataclass
class VehicleCandidate:
    source_url: str
    final_url: str
    domain: str
    title: Optional[str]
    brand: Optional[str]
    model: Optional[str]
    variant: Optional[str]
    price_text: Optional[str]
    mileage_text: Optional[str]
    power_text: Optional[str]
    torque_text: Optional[str]
    engine_cc_text: Optional[str]
    seating_text: Optional[str]
    battery_text: Optional[str]
    range_text: Optional[str]
    fuel_type: Optional[str]
    transmission: Optional[str]
    body_type: Optional[str]
    launch_status: Optional[str]
    body_text: Optional[str]
    source_type: Optional[str]
    confidence_score: float
    fetched_at: str
    content_hash: Optional[str]


# =============================================================================
# UTILITIES
# =============================================================================

def ensure_output_dir() -> None:
    os.makedirs(OUTPUT_DIR, exist_ok=True)


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8", errors="ignore")).hexdigest()


def norm_url(url: str) -> str:
    p = urlparse(url)
    scheme = p.scheme.lower() if p.scheme else "https"
    netloc = p.netloc.lower()
    path = re.sub(r"/{2,}", "/", p.path or "/")
    query_pairs = []
    if p.query:
        for part in p.query.split("&"):
            if not part:
                continue
            key = part.split("=", 1)[0].lower()
            if key.startswith("utm_") or key in {"gclid", "fbclid", "ref", "yclid"}:
                continue
            query_pairs.append(part)
    query = "&".join(query_pairs)
    return urlunparse((scheme, netloc, path.rstrip("/") or "/", "", query, ""))


def url_domain(url: str) -> str:
    return urlparse(url).netloc.lower()


def write_jsonl(path: str, obj: Dict[str, Any]) -> None:
    with open(path, "a", encoding="utf-8") as f:
        f.write(json.dumps(obj, ensure_ascii=False) + "\n")


def log_error(stage: str, url: str, error: str) -> None:
    write_jsonl(ERRORS_PATH, {
        "ts": now_iso(),
        "stage": stage,
        "url": url,
        "error": error,
    })


def is_allowed_domain(url: str) -> bool:
    if not ALLOWED_DOMAINS:
        return True
    return url_domain(url) in ALLOWED_DOMAINS


# =============================================================================
# ROBOTS
# =============================================================================

class RobotsCache:
    def __init__(self) -> None:
        self.cache: Dict[str, Optional[RobotFileParser]] = {}

    def get(self, url: str) -> Optional[RobotFileParser]:
        domain = url_domain(url)
        if domain in self.cache:
            return self.cache[domain]

        rp = RobotFileParser()
        robots_url = f"{urlparse(url).scheme}://{domain}/robots.txt"
        try:
            rp.set_url(robots_url)
            rp.read()
            self.cache[domain] = rp
            return rp
        except Exception:
            self.cache[domain] = None
            return None

    def allowed(self, url: str) -> bool:
        if not RESPECT_ROBOTS:
            return True
        rp = self.get(url)
        if rp is None:
            return True
        try:
            return rp.can_fetch(USER_AGENT, url)
        except Exception:
            return True


# =============================================================================
# HTTP
# =============================================================================

def make_session() -> requests.Session:
    s = requests.Session()
    s.headers.update({
        "User-Agent": USER_AGENT,
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language": "en-IN,en;q=0.9,en-US;q=0.7",
        "Cache-Control": "no-cache",
        "Pragma": "no-cache",
    })
    return s


def fetch(session: requests.Session, url: str, retries: int = 3) -> Tuple[Optional[requests.Response], Optional[str]]:
    last_err = None
    for attempt in range(retries):
        try:
            resp = session.get(url, timeout=REQUEST_TIMEOUT, allow_redirects=True)
            return resp, None
        except Exception as e:
            last_err = str(e)
            time.sleep(min(2 ** attempt, 8))
    return None, last_err


# =============================================================================
# SITEMAPS
# =============================================================================

def parse_sitemap_xml(xml_bytes: bytes) -> Tuple[List[str], List[str]]:
    child_sitemaps: List[str] = []
    urls: List[str] = []

    try:
        root = ET.fromstring(xml_bytes)
    except Exception:
        return child_sitemaps, urls

    def strip_ns(tag: str) -> str:
        return tag.split("}", 1)[-1].lower()

    for node in root:
        tag = strip_ns(node.tag)
        if tag == "sitemap":
            loc = node.findtext(".//{*}loc")
            if loc:
                child_sitemaps.append(loc.strip())
        elif tag == "url":
            loc = node.findtext(".//{*}loc")
            if loc:
                urls.append(loc.strip())

    return child_sitemaps, urls


def discover_sitemap_urls(session: requests.Session, start_url: str) -> Set[str]:
    discovered: Set[str] = set()
    p = urlparse(start_url)
    candidates = [
        f"{p.scheme}://{p.netloc}/sitemap.xml",
        f"{p.scheme}://{p.netloc}/sitemap_index.xml",
        f"{p.scheme}://{p.netloc}/sitemap-index.xml",
    ]

    seen_sitemaps: Set[str] = set()
    q = deque(candidates)

    while q:
        sm = q.popleft()
        if sm in seen_sitemaps:
            continue
        seen_sitemaps.add(sm)

        resp, err = fetch(session, sm, retries=2)
        if not resp or resp.status_code >= 400:
            continue

        ctype = resp.headers.get("Content-Type", "").lower()
        if "xml" not in ctype and not sm.endswith(".xml"):
            continue

        child_sitemaps, urls = parse_sitemap_xml(resp.content)
        for u in urls:
            discovered.add(norm_url(u))
        for child in child_sitemaps:
            if child not in seen_sitemaps:
                q.append(child)

    return discovered


# =============================================================================
# HTML / PDF EXTRACTION
# =============================================================================

def extract_jsonld(soup: BeautifulSoup) -> List[Dict[str, Any]]:
    results: List[Dict[str, Any]] = []
    for tag in soup.find_all("script", attrs={"type": re.compile(r"ld\+json", re.I)}):
        try:
            raw = tag.get_text(strip=True)
            if not raw:
                continue
            parsed = json.loads(raw)
            if isinstance(parsed, dict):
                results.append(parsed)
            elif isinstance(parsed, list):
                results.extend([x for x in parsed if isinstance(x, dict)])
        except Exception:
            continue
    return results


def extract_tables(soup: BeautifulSoup) -> List[List[List[str]]]:
    tables: List[List[List[str]]] = []
    for table in soup.find_all("table"):
        rows: List[List[str]] = []
        for tr in table.find_all("tr"):
            cells = tr.find_all(["th", "td"])
            row = [re.sub(r"\s+", " ", c.get_text(" ", strip=True)) for c in cells]
            if row:
                rows.append(row)
        if rows:
            tables.append(rows)
    return tables


def extract_visible_text(soup: BeautifulSoup) -> str:
    for tag in soup(["script", "style", "noscript"]):
        tag.extract()
    text = soup.get_text("\n", strip=True)
    lines = [re.sub(r"\s+", " ", line).strip() for line in text.splitlines()]
    lines = [line for line in lines if line]
    return "\n".join(lines)


def extract_links(soup: BeautifulSoup, base_url: str) -> List[str]:
    links = []
    for a in soup.find_all("a", href=True):
        href = a["href"].strip()
        if not href or href.startswith(("javascript:", "mailto:", "tel:")):
            continue
        links.append(norm_url(urljoin(base_url, href)))
    return sorted(set(links))


def extract_image_urls(soup: BeautifulSoup, base_url: str) -> List[str]:
    imgs = []
    for img in soup.find_all("img"):
        src = img.get("src") or img.get("data-src") or img.get("data-lazy-src")
        if src:
            imgs.append(norm_url(urljoin(base_url, src.strip())))
    return sorted(set(imgs))


def extract_pdf_text(pdf_bytes: bytes) -> str:
    if PdfReader is None:
        return ""
    try:
        reader = PdfReader(io.BytesIO(pdf_bytes))
        parts = []
        for page in reader.pages:
            try:
                parts.append(page.extract_text() or "")
            except Exception:
                parts.append("")
        return "\n".join(parts).strip()
    except Exception:
        return ""


def guess_content_type(url: str, resp: requests.Response) -> str:
    ctype = resp.headers.get("Content-Type", "").lower()
    if ctype:
        return ctype.split(";", 1)[0].strip()
    if url.lower().endswith(".pdf"):
        return "application/pdf"
    return "text/html"


def extract_html_record(source_url: str, final_url: str, resp: requests.Response, depth: int) -> ScrapeRecord:
    soup = BeautifulSoup(resp.text, "lxml")
    title = soup.title.string.strip() if soup.title and soup.title.string else None

    meta_description = None
    desc_tag = soup.find("meta", attrs={"name": re.compile(r"description", re.I)})
    if desc_tag and desc_tag.get("content"):
        meta_description = re.sub(r"\s+", " ", desc_tag["content"]).strip()

    canonical = None
    canon_tag = soup.find("link", rel=re.compile(r"canonical", re.I))
    if canon_tag and canon_tag.get("href"):
        canonical = norm_url(urljoin(final_url, canon_tag["href"]))

    h1 = None
    h1_tag = soup.find("h1")
    if h1_tag:
        h1 = re.sub(r"\s+", " ", h1_tag.get_text(" ", strip=True)).strip()

    text = extract_visible_text(soup)
    content_hash = sha256_text(text or resp.text or "")
    return ScrapeRecord(
        source_url=source_url,
        final_url=final_url,
        url_hash=sha256_text(final_url),
        fetched_at=now_iso(),
        content_type=resp.headers.get("Content-Type", ""),
        status_code=resp.status_code,
        domain=url_domain(final_url),
        page_depth=depth,
        title=title,
        meta_description=meta_description,
        canonical_url=canonical,
        h1=h1,
        text_content=text,
        extracted_tables=extract_tables(soup),
        links=extract_links(soup, final_url),
        image_urls=extract_image_urls(soup, final_url),
        raw_jsonld=extract_jsonld(soup),
        content_hash=content_hash,
    )


def extract_pdf_record(source_url: str, final_url: str, resp: requests.Response, depth: int) -> ScrapeRecord:
    pdf_text = extract_pdf_text(resp.content)
    content_hash = sha256_text(pdf_text or resp.content.decode("latin1", errors="ignore"))
    return ScrapeRecord(
        source_url=source_url,
        final_url=final_url,
        url_hash=sha256_text(final_url),
        fetched_at=now_iso(),
        content_type=resp.headers.get("Content-Type", ""),
        status_code=resp.status_code,
        domain=url_domain(final_url),
        page_depth=depth,
        pdf_text=pdf_text,
        content_hash=content_hash,
    )


# =============================================================================
# INDIAN VEHICLE FIELD EXTRACTION
# =============================================================================

def first_match(pattern: re.Pattern, text: str) -> Optional[str]:
    m = pattern.search(text or "")
    return m.group(0).strip() if m else None


def extract_brand_model_variant(title: Optional[str], h1: Optional[str], text: str) -> Tuple[Optional[str], Optional[str], Optional[str]]:
    candidates = [x for x in [h1, title] if x]
    raw = candidates[0] if candidates else ""
    raw = re.sub(r"\s+", " ", raw).strip()

    # Simple heuristic split: "Brand Model Variant"
    tokens = raw.split()
    if len(tokens) >= 2:
        brand = tokens[0]
        model = tokens[1]
        variant = " ".join(tokens[2:]) if len(tokens) > 2 else None
        return brand, model, variant
    return None, None, None


def extract_fuel_type(text: str) -> Optional[str]:
    fuels = [
        "Petrol", "Diesel", "CNG", "LPG", "Electric", "Hybrid", "Plug-in Hybrid",
        "Hybrid Electric", "EV", "Petrol+CNG", "Hydrogen"
    ]
    lowered = text.lower()
    for f in fuels:
        if f.lower() in lowered:
            return f
    return None


def extract_transmission(text: str) -> Optional[str]:
    options = [
        "Manual", "Automatic", "AMT", "DCT", "CVT", "e-CVT", "IVT", "AT", "MT"
    ]
    lowered = text.lower()
    for o in options:
        if o.lower() in lowered:
            return o
    return None


def extract_body_type(text: str) -> Optional[str]:
    types = [
        "Hatchback", "Sedan", "SUV", "Compact SUV", "Midsize SUV",
        "MPV", "MUV", "Coupe", "Convertible", "Luxury Sedan",
        "Luxury SUV", "Wagon", "Pickup"
    ]
    lowered = text.lower()
    for t in types:
        if t.lower() in lowered:
            return t
    return None


def extract_launch_status(text: str) -> Optional[str]:
    lowered = text.lower()
    if "upcoming" in lowered:
        return "Upcoming"
    if "facelift" in lowered:
        return "Facelift"
    if "discontinue" in lowered or "discontinued" in lowered:
        return "Discontinued"
    if "launched" in lowered or "available" in lowered:
        return "Launched"
    return None


def infer_candidate(record: ScrapeRecord) -> VehicleCandidate:
    text = record.text_content or record.pdf_text or ""
    title = record.title
    h1 = record.h1

    brand, model, variant = extract_brand_model_variant(title, h1, text)
    price_text = first_match(INDIAN_PRICE_RE, text)
    mileage_text = first_match(MILEAGE_RE, text)
    power_text = first_match(POWER_RE, text)
    torque_text = first_match(TORQUE_RE, text)
    engine_cc_text = first_match(ENGINE_CC_RE, text)
    seating_text = first_match(SEATING_RE, text)
    battery_text = first_match(BATTERY_RE, text)
    range_text = first_match(RANGE_RE, text)
    fuel_type = extract_fuel_type(text)
    transmission = extract_transmission(text)
    body_type = extract_body_type(text)
    launch_status = extract_launch_status(text)

    score = 0.0
    score += 0.2 if price_text else 0.0
    score += 0.2 if mileage_text else 0.0
    score += 0.1 if power_text else 0.0
    score += 0.1 if torque_text else 0.0
    score += 0.1 if engine_cc_text else 0.0
    score += 0.1 if fuel_type else 0.0
    score += 0.1 if transmission else 0.0
    score += 0.1 if body_type else 0.0
    score += 0.1 if launch_status else 0.0

    # Normalize to 0-100
    confidence = round(min(score, 1.0) * 100.0, 2)

    return VehicleCandidate(
        source_url=record.source_url,
        final_url=record.final_url,
        domain=record.domain,
        title=record.title,
        brand=brand,
        model=model,
        variant=variant,
        price_text=price_text,
        mileage_text=mileage_text,
        power_text=power_text,
        torque_text=torque_text,
        engine_cc_text=engine_cc_text,
        seating_text=seating_text,
        battery_text=battery_text,
        range_text=range_text,
        fuel_type=fuel_type,
        transmission=transmission,
        body_type=body_type,
        launch_status=launch_status,
        body_text=text[:20000] if text else None,
        source_type="pdf" if record.pdf_text else "html",
        confidence_score=confidence,
        fetched_at=record.fetched_at,
        content_hash=record.content_hash,
    )


# =============================================================================
# MYSQL STAGING
# =============================================================================

def mysql_connect():
    if pymysql is None:
        raise RuntimeError("pymysql not installed")
    return pymysql.connect(
        host=MYSQL_CONFIG["host"],
        user=MYSQL_CONFIG["user"],
        password=MYSQL_CONFIG["password"],
        database=MYSQL_CONFIG["database"],
        charset=MYSQL_CONFIG["charset"],
        autocommit=True,
    )


def ensure_tables(conn) -> None:
    sql1 = """
    CREATE TABLE IF NOT EXISTS raw_indian_vehicle_pages (
        id BIGINT NOT NULL AUTO_INCREMENT,
        source_url VARCHAR(2048) NOT NULL,
        final_url VARCHAR(2048) NOT NULL,
        url_hash CHAR(64) NOT NULL,
        fetched_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        content_type VARCHAR(255) DEFAULT NULL,
        status_code INT DEFAULT NULL,
        domain VARCHAR(255) DEFAULT NULL,
        page_depth INT DEFAULT NULL,
        title TEXT DEFAULT NULL,
        meta_description TEXT DEFAULT NULL,
        canonical_url VARCHAR(2048) DEFAULT NULL,
        h1 TEXT DEFAULT NULL,
        text_content LONGTEXT DEFAULT NULL,
        extracted_tables LONGTEXT DEFAULT NULL,
        links LONGTEXT DEFAULT NULL,
        image_urls LONGTEXT DEFAULT NULL,
        raw_jsonld LONGTEXT DEFAULT NULL,
        pdf_text LONGTEXT DEFAULT NULL,
        content_hash CHAR(64) DEFAULT NULL,
        PRIMARY KEY (id),
        UNIQUE KEY uq_raw_indian_vehicle_pages_urlhash (url_hash),
        KEY idx_domain (domain),
        KEY idx_status (status_code)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    """
    sql2 = """
    CREATE TABLE IF NOT EXISTS indian_vehicle_candidates (
        candidate_id BIGINT NOT NULL AUTO_INCREMENT,
        source_url VARCHAR(2048) NOT NULL,
        final_url VARCHAR(2048) NOT NULL,
        domain VARCHAR(255) DEFAULT NULL,
        fetched_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        title TEXT DEFAULT NULL,
        brand VARCHAR(150) DEFAULT NULL,
        model VARCHAR(150) DEFAULT NULL,
        variant VARCHAR(200) DEFAULT NULL,
        price_text VARCHAR(100) DEFAULT NULL,
        mileage_text VARCHAR(100) DEFAULT NULL,
        power_text VARCHAR(100) DEFAULT NULL,
        torque_text VARCHAR(100) DEFAULT NULL,
        engine_cc_text VARCHAR(100) DEFAULT NULL,
        seating_text VARCHAR(100) DEFAULT NULL,
        battery_text VARCHAR(100) DEFAULT NULL,
        range_text VARCHAR(100) DEFAULT NULL,
        fuel_type VARCHAR(50) DEFAULT NULL,
        transmission VARCHAR(50) DEFAULT NULL,
        body_type VARCHAR(100) DEFAULT NULL,
        launch_status VARCHAR(50) DEFAULT NULL,
        confidence_score DECIMAL(5,2) DEFAULT NULL,
        source_type VARCHAR(20) DEFAULT NULL,
        content_hash CHAR(64) DEFAULT NULL,
        body_text LONGTEXT DEFAULT NULL,
        PRIMARY KEY (candidate_id),
        UNIQUE KEY uq_indian_candidate_hash (content_hash),
        KEY idx_indian_candidate_brand_model (brand, model),
        KEY idx_indian_candidate_confidence (confidence_score)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    """
    with conn.cursor() as cur:
        cur.execute(sql1)
        cur.execute(sql2)


def insert_raw(conn, rec: ScrapeRecord) -> None:
    sql = """
    INSERT INTO raw_indian_vehicle_pages (
        source_url, final_url, url_hash, fetched_at, content_type, status_code,
        domain, page_depth, title, meta_description, canonical_url, h1,
        text_content, extracted_tables, links, image_urls, raw_jsonld,
        pdf_text, content_hash
    ) VALUES (
        %(source_url)s, %(final_url)s, %(url_hash)s, %(fetched_at)s, %(content_type)s, %(status_code)s,
        %(domain)s, %(page_depth)s, %(title)s, %(meta_description)s, %(canonical_url)s, %(h1)s,
        %(text_content)s, %(extracted_tables)s, %(links)s, %(image_urls)s, %(raw_jsonld)s,
        %(pdf_text)s, %(content_hash)s
    )
    ON DUPLICATE KEY UPDATE
        fetched_at=VALUES(fetched_at),
        content_type=VALUES(content_type),
        status_code=VALUES(status_code),
        title=VALUES(title),
        meta_description=VALUES(meta_description),
        canonical_url=VALUES(canonical_url),
        h1=VALUES(h1),
        text_content=VALUES(text_content),
        extracted_tables=VALUES(extracted_tables),
        links=VALUES(links),
        image_urls=VALUES(image_urls),
        raw_jsonld=VALUES(raw_jsonld),
        pdf_text=VALUES(pdf_text),
        content_hash=VALUES(content_hash);
    """
    payload = asdict(rec)
    payload["extracted_tables"] = json.dumps(payload["extracted_tables"], ensure_ascii=False) if payload["extracted_tables"] is not None else None
    payload["links"] = json.dumps(payload["links"], ensure_ascii=False) if payload["links"] is not None else None
    payload["image_urls"] = json.dumps(payload["image_urls"], ensure_ascii=False) if payload["image_urls"] is not None else None
    payload["raw_jsonld"] = json.dumps(payload["raw_jsonld"], ensure_ascii=False) if payload["raw_jsonld"] is not None else None

    with conn.cursor() as cur:
        cur.execute(sql, payload)


def insert_candidate(conn, cand: VehicleCandidate) -> None:
    sql = """
    INSERT INTO indian_vehicle_candidates (
        source_url, final_url, domain, fetched_at, title,
        brand, model, variant, price_text, mileage_text, power_text,
        torque_text, engine_cc_text, seating_text, battery_text, range_text,
        fuel_type, transmission, body_type, launch_status, confidence_score,
        source_type, content_hash, body_text
    ) VALUES (
        %(source_url)s, %(final_url)s, %(domain)s, %(fetched_at)s, %(title)s,
        %(brand)s, %(model)s, %(variant)s, %(price_text)s, %(mileage_text)s, %(power_text)s,
        %(torque_text)s, %(engine_cc_text)s, %(seating_text)s, %(battery_text)s, %(range_text)s,
        %(fuel_type)s, %(transmission)s, %(body_type)s, %(launch_status)s, %(confidence_score)s,
        %(source_type)s, %(content_hash)s, %(body_text)s
    )
    ON DUPLICATE KEY UPDATE
        fetched_at=VALUES(fetched_at),
        title=VALUES(title),
        brand=VALUES(brand),
        model=VALUES(model),
        variant=VALUES(variant),
        price_text=VALUES(price_text),
        mileage_text=VALUES(mileage_text),
        power_text=VALUES(power_text),
        torque_text=VALUES(torque_text),
        engine_cc_text=VALUES(engine_cc_text),
        seating_text=VALUES(seating_text),
        battery_text=VALUES(battery_text),
        range_text=VALUES(range_text),
        fuel_type=VALUES(fuel_type),
        transmission=VALUES(transmission),
        body_type=VALUES(body_type),
        launch_status=VALUES(launch_status),
        confidence_score=VALUES(confidence_score),
        source_type=VALUES(source_type),
        body_text=VALUES(body_text);
    """
    with conn.cursor() as cur:
        cur.execute(sql, asdict(cand))


# =============================================================================
# CRAWLER
# =============================================================================

def crawl() -> None:
    ensure_output_dir()

    if not START_URLS:
        raise SystemExit("Set START_URLS before running.")

    # ==================================================
    # DEBUG VERSION CHECKPOINTS - STARTUP
    # ==================================================
    print("===================================")
    print("AUTOPREDATOR INDIA SCRAPER STARTED")
    print("===================================")
    print("Loaded START_URLS:", START_URLS)
    print("Allowed Domains:", ALLOWED_DOMAINS)
    print("Output Directory:", OUTPUT_DIR)
    print("===================================")

    session = make_session()
    robots = RobotsCache()

    seen: Set[str] = set()
    per_domain_count: Dict[str, int] = defaultdict(int)
    frontier = deque()

    for start in START_URLS:
        start_n = norm_url(start)
        frontier.append((start_n, start_n, 0))
        try:
            for sm_url in discover_sitemap_urls(session, start_n):
                frontier.append((sm_url, sm_url, 1))
        except Exception as e:
            log_error("sitemap_discovery", start_n, str(e))

    # ==================================================
    # DEBUG VERSION CHECKPOINTS - INITIAL FRONTIER
    # ==================================================
    print(f"Initial frontier size: {len(frontier)}")

    mysql_conn = None
    if ENABLE_MYSQL:
        mysql_conn = mysql_connect()
        ensure_tables(mysql_conn)

    stats = {
        "pages_seen": 0,
        "html_pages": 0,
        "pdf_pages": 0,
        "candidates_saved": 0,
        "errors": 0,
    }

    while frontier:
        # ==================================================
        # DEBUG VERSION CHECKPOINTS - QUEUE STATUS
        # ==================================================
        print(f"[QUEUE] Remaining URLs: {len(frontier)}")

        source_url, current_url, depth = frontier.popleft()
        current_url = norm_url(current_url)

# ==================================================
        # DEBUG VERSION CHECKPOINTS - SCRAPING STATUS
        # ==================================================
        print(f"[SCRAPING] Depth {depth} | URL: {current_url}")

        if current_url in seen:
            continue
        seen.add(current_url)

        if depth > MAX_DEPTH:
            continue

        if not is_allowed_domain(current_url):
            continue

        domain = url_domain(current_url)
        if per_domain_count[domain] >= MAX_PAGES_PER_DOMAIN:
            continue

        if RESPECT_ROBOTS and not robots.allowed(current_url):
            continue

        resp, err = fetch(session, current_url)
        if err or resp is None:
            # ==================================================
            # DEBUG VERSION CHECKPOINTS - ERROR
            # ==================================================
            print(f"[ERROR] {current_url} -> {err or 'unknown error'}")
            stats["errors"] += 1
            log_error("fetch", current_url, err or "unknown error")
            continue

        per_domain_count[domain] += 1
        stats["pages_seen"] += 1
        final_url = norm_url(resp.url)
        ctype = guess_content_type(final_url, resp)

        # ==================================================
        # DEBUG VERSION CHECKPOINTS - FETCHED STATUS
        # ==================================================
        print(f"[FETCHED] Status: {resp.status_code} | Final URL: {final_url}")

        try:
            if ctype in PDF_CONTENT_TYPES or final_url.lower().endswith(".pdf"):
                rec = extract_pdf_record(source_url, final_url, resp, depth)
                stats["pdf_pages"] += 1
            elif ctype in HTML_CONTENT_TYPES or "html" in ctype:
                rec = extract_html_record(source_url, final_url, resp, depth)
                stats["html_pages"] += 1
            else:
                rec = ScrapeRecord(
                    source_url=source_url,
                    final_url=final_url,
                    url_hash=sha256_text(final_url),
                    fetched_at=now_iso(),
                    content_type=ctype,
                    status_code=resp.status_code,
                    domain=domain,
                    page_depth=depth,
                    content_hash=sha256_text(resp.content.decode("latin1", errors="ignore")),
                )

            # ==================================================
            # DEBUG VERSION CHECKPOINTS - EXTRACTED TITLE
            # ==================================================
            print(f"[EXTRACTED] Title: {rec.title}")

            write_jsonl(JSONL_PATH, asdict(rec))
            if mysql_conn is not None:
                insert_raw(mysql_conn, rec)

            cand = infer_candidate(rec)

            # ==================================================
            # DEBUG VERSION CHECKPOINTS - CANDIDATE CONFIDENCE
            # ==================================================
            print(f"[CANDIDATE] Confidence Score: {cand.confidence_score}")

            if cand.confidence_score >= 30.0:
                write_jsonl(os.path.join(OUTPUT_DIR, "vehicle_candidates.jsonl"), asdict(cand))
                if mysql_conn is not None:
                    insert_candidate(mysql_conn, cand)
                stats["candidates_saved"] += 1

            # enqueue discovered links
            if rec.links:
                for link in rec.links:
                    if link in seen:
                        continue
                    if not is_allowed_domain(link):
                        continue
                    if STRICT_DOMAIN_LOCK and url_domain(link) != domain:
                        continue
                    if RESPECT_ROBOTS and not robots.allowed(link):
                        continue
                    frontier.append((current_url, link, depth + 1))

            time.sleep(RATE_LIMIT_SECONDS)

        except Exception as e:
            stats["errors"] += 1
            log_error("extract_store", current_url, str(e))

    if mysql_conn is not None:
        mysql_conn.close()

    stats["domains"] = dict(per_domain_count)
    stats["finished_at"] = now_iso()
    with open(SUMMARY_PATH, "w", encoding="utf-8") as f:
        json.dump(stats, f, ensure_ascii=False, indent=2)

    # ==================================================
    # DEBUG VERSION CHECKPOINTS - FINAL SUMMARY
    # ==================================================
    print("===================================")
    print("SCRAPE COMPLETE")
    print("Pages Seen:", stats["pages_seen"])
    print("Candidates Saved:", stats["candidates_saved"])
    print("Errors:", stats["errors"])
    print("===================================")


# =============================================================================
# MAIN
# =============================================================================

if __name__ == "__main__":
    try:
        crawl()
    except KeyboardInterrupt:
        print("Stopped by user.")
    except Exception as exc:
        print(f"Fatal error: {exc}", file=sys.stderr)
        sys.exit(1)