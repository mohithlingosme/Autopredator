#!/usr/bin/env python3
"""
Reindex listings + catalog documents from PostgreSQL into OpenSearch.

"""
from __future__ import annotations

import os
import sys
import json
from pathlib import Path
from typing import Dict, Iterable, List


try:
    import psycopg
    from opensearchpy import OpenSearch, helpers
except ImportError as exc:
    missing = str(exc).split("'")[1]
    print(
        f"Missing dependency: {missing}. Install with "
        "'pip install psycopg[binary] opensearch-py'."
    )
    sys.exit(1)


DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://autopredator:autopredator@localhost:5432/autopredator")
if "+asyncpg" in DATABASE_URL:
    DATABASE_URL = DATABASE_URL.replace("+asyncpg", "")
OPENSEARCH_URL = os.getenv("OPENSEARCH_URL", "http://localhost:9200")


def fetch_listings(conn) -> List[Dict]:
    query = """
        SELECT
            l.id AS listing_id,
            l.variant_id,
            l.seller_org_id,
            l.listing_type,
            l.price,
            l.year,
            l.km_driven,
            l.status,
            l.created_at,
            c.name AS city_name,
            c.id AS city_id,
            s.code AS state_code,
            v.name AS variant_name,
            m.name AS model_name,
            mf.name AS family_name,
            manu.name AS manufacturer_name,
            ft.label AS fuel_type,
            tr.label AS transmission,
            bt.label AS body_type
        FROM listings l
        LEFT JOIN cities c ON c.id = l.city_id
        LEFT JOIN states s ON s.id = c.state_id
        LEFT JOIN variants v ON v.id = l.variant_id
        LEFT JOIN models m ON m.id = v.model_id
        LEFT JOIN model_families mf ON mf.id = m.family_id
        LEFT JOIN manufacturers manu ON manu.id = mf.manufacturer_id
        LEFT JOIN fuel_types ft ON ft.id = l.fuel_type_id
        LEFT JOIN transmissions tr ON tr.id = l.transmission_id
        LEFT JOIN body_types bt ON bt.id = l.body_type_id
        ORDER BY l.created_at DESC
    """
    with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
        cur.execute(query)
        return cur.fetchall()


def fetch_variants(conn) -> List[Dict]:
    query = """
        SELECT
            v.id AS variant_id,
            v.name AS variant_name,
            v.msrp_ex_showroom,
            v.year_start,
            v.year_end,
            v.status,
            v.created_at,
            v.model_id,
            m.name AS model_name,
            mf.id AS family_id,
            mf.name AS family_name,
            manu.id AS manufacturer_id,
            manu.name AS manufacturer_name,
            ft.label AS fuel_type,
            tr.label AS transmission,
            bt.label AS body_type,
            vs.engine_type,
            vs.displacement_cc,
            vs.power_hp,
            vs.torque_nm,
            vs.seating_capacity,
            vs.mileage_kmpl,
            vs.emission_standard
        FROM variants v
        LEFT JOIN models m ON m.id = v.model_id
        LEFT JOIN model_families mf ON mf.id = m.family_id
        LEFT JOIN manufacturers manu ON manu.id = mf.manufacturer_id
        LEFT JOIN fuel_types ft ON ft.id = v.fuel_type_id
        LEFT JOIN transmissions tr ON tr.id = v.transmission_id
        LEFT JOIN body_types bt ON bt.id = v.body_type_id
        LEFT JOIN variant_specs vs ON vs.variant_id = v.id
        ORDER BY v.created_at DESC
    """
    with conn.cursor(row_factory=psycopg.rows.dict_row) as cur:
        cur.execute(query)
        return cur.fetchall()


def listing_actions(rows: Iterable[Dict]) -> Iterable[Dict]:
    for row in rows:
        yield {
            "_op_type": "index",
            "_index": "listing_search",
            "_id": str(row["listing_id"]),
            "_source": {
                **{k: v for k, v in row.items() if v is not None},
                "title": f"{row.get('manufacturer_name') or ''} {row.get('model_name') or ''} {row.get('variant_name') or ''}".strip(),
            },
        }


def catalog_actions(rows: Iterable[Dict]) -> Iterable[Dict]:
    for row in rows:
        yield {
            "_op_type": "index",
            "_index": "catalog_search",
            "_id": str(row["variant_id"]),
            "_source": {k: v for k, v in row.items() if v is not None},
        }


def ensure_indices(client: OpenSearch) -> None:
    templates = {
        "listing_search": Path(__file__).resolve().parent.parent / "infra" / "db" / "opensearch" / "listing_search.json",
        "catalog_search": Path(__file__).resolve().parent.parent / "infra" / "db" / "opensearch" / "catalog_search.json",
    }

    for name, path in templates.items():
        if not path.exists():
            continue
        body = json.loads(path.read_text())
        if not client.indices.exists_index_template(name=name):
            client.indices.put_index_template(name=name, body=body)

    for index in templates.keys():
        if not client.indices.exists(index=index):
            client.indices.create(index=index)


def main() -> None:
    client = OpenSearch([OPENSEARCH_URL])
    ensure_indices(client)

    with psycopg.connect(DATABASE_URL) as conn:
        listing_docs = fetch_listings(conn)
        variant_docs = fetch_variants(conn)

    print(f"[INFO] Indexing {len(listing_docs)} listings")
    helpers.bulk(client, listing_actions(listing_docs))
    print(f"[INFO] Indexing {len(variant_docs)} variants")
    helpers.bulk(client, catalog_actions(variant_docs))
    print("[DONE] Reindex complete")


if __name__ == "__main__":
    main()
