#!/usr/bin/env python3
"""
Lightweight connectivity and schema checks for the local database stack.

Validates:
- PostgreSQL core tables + indexes
- Redis reachability
- OpenSearch index presence
- ClickHouse table presence
"""
from __future__ import annotations

import os
import sys
from typing import List


def _fail(msg: str) -> None:
    print(f"[FAIL] {msg}")
    sys.exit(1)


try:
    import psycopg
    import redis
    from opensearchpy import OpenSearch
    import clickhouse_connect
except ImportError as exc:  # pragma: no cover - dependency hint
    missing = str(exc).split("'")[1]
    _fail(
        f"Missing dependency: {missing}. Install with "
        "'pip install psycopg[binary] redis opensearch-py clickhouse-connect'."
    )


def check_postgres() -> None:
    url = os.getenv("DATABASE_URL", "postgresql://autopredator:autopredator@localhost:5432/autopredator")
    if "+asyncpg" in url:
        url = url.replace("+asyncpg", "")
    print(f"[INFO] Checking PostgreSQL at {url}")
    with psycopg.connect(url) as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT table_name FROM information_schema.tables
                WHERE table_schema='public' AND table_name IN (
                    'organizations','listings','price_history','variants','leads'
                )
                """
            )
            tables = {row[0] for row in cur.fetchall()}
            expected = {"organizations", "listings", "price_history", "variants", "leads"}
            if tables != expected:
                _fail(f"Missing tables: {expected - tables}")

            cur.execute(
                """
                SELECT indexname FROM pg_indexes
                WHERE tablename IN ('listings','price_history','leads')
                """
            )
            idx = {row[0] for row in cur.fetchall()}
            required = {
                "idx_listings_filters_city_status",
                "idx_price_history_variant_city_date",
                "idx_leads_seller_status_created",
            }
            if not required.issubset(idx):
                _fail(f"Missing indexes: {required - idx}")

            cur.execute("SELECT conname FROM pg_constraint WHERE conname = 'pk_price_history'")
            if not cur.fetchone():
                _fail("Primary key missing on price_history")
    print("[PASS] PostgreSQL schema OK")


def check_redis() -> None:
    url = os.getenv("REDIS_URL", "redis://localhost:6379/0")
    print(f"[INFO] Checking Redis at {url}")
    client = redis.Redis.from_url(url)
    if client.ping() is not True:
        _fail("Redis ping failed")
    print("[PASS] Redis reachable")


def check_opensearch() -> None:
    url = os.getenv("OPENSEARCH_URL", "http://localhost:9200")
    print(f"[INFO] Checking OpenSearch at {url}")
    client = OpenSearch([url])
    for index in ("listing_search", "catalog_search"):
        if not client.indices.exists(index=index):
            _fail(f"Index '{index}' not found; apply templates from infra/db/opensearch and create the index.")
    print("[PASS] OpenSearch indexes present")


def check_clickhouse() -> None:
    url = os.getenv("CLICKHOUSE_URL", "http://autopredator:autopredator@localhost:8123/autopredator")
    print(f"[INFO] Checking ClickHouse at {url}")
    client = clickhouse_connect.get_client(url=url)
    tables = client.query(
        "SELECT name FROM system.tables WHERE database = 'autopredator' "
        "AND name IN ('events_page_view','events_search','events_compare','events_lead')"
    ).result_rows
    found = {row[0] for row in tables}
    expected = {"events_page_view", "events_search", "events_compare", "events_lead"}
    if found != expected:
        _fail(f"Missing ClickHouse tables: {expected - found}")
    print("[PASS] ClickHouse tables present")


def main() -> None:
    checks: List[callable] = [check_postgres, check_redis, check_opensearch, check_clickhouse]
    for fn in checks:
        fn()
    print("[DONE] db-test complete")


if __name__ == "__main__":
    main()
