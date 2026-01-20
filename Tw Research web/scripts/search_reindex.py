"""
Rebuild search indexes from Postgres into OpenSearch.

Requires environment variables (see infra/.env.example):
- POSTGRES_HOST, POSTGRES_PORT, POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD
- OPENSEARCH_HOST, OPENSEARCH_PORT, OPENSEARCH_SCHEME
- LISTINGS_SEARCH_INDEX (optional, default: listings_search)
- CATALOG_SUGGEST_INDEX (optional, default: catalog_suggest)
"""

import json
import os
import sys
from pathlib import Path

import psycopg2
import psycopg2.extras
from opensearchpy import OpenSearch, helpers


ROOT = Path(__file__).resolve().parent.parent
TEMPLATES_DIR = ROOT / "infra" / "search" / "templates"


def opensearch_client() -> OpenSearch:
    host = os.getenv("OPENSEARCH_HOST", "localhost")
    port = int(os.getenv("OPENSEARCH_PORT", "9200"))
    scheme = os.getenv("OPENSEARCH_SCHEME", "http")
    return OpenSearch(
        hosts=[{"host": host, "port": port, "scheme": scheme}],
        http_compress=True,
        timeout=60,
    )


def postgres_conn():
    return psycopg2.connect(
        host=os.getenv("POSTGRES_HOST", "localhost"),
        port=int(os.getenv("POSTGRES_PORT", "5432")),
        dbname=os.getenv("POSTGRES_DB", "autopredator_dev"),
        user=os.getenv("POSTGRES_USER", "autopredator"),
        password=os.getenv("POSTGRES_PASSWORD", "password"),
    )


def apply_index_template(client: OpenSearch, name: str, filename: str) -> None:
    body = json.loads((TEMPLATES_DIR / filename).read_text())
    client.indices.put_index_template(name=name, body=body)


def ensure_index(client: OpenSearch, name: str) -> None:
    if client.indices.exists(index=name):
        return
    client.indices.create(index=name)


def fetch_listings(conn):
    query = """
    SELECT
        l.id,
        l.org_id,
        l.variant_id,
        l.city_id,
        cities.name AS city,
        l.listing_type,
        l.status,
        l.price,
        l.year,
        l.km,
        ft.name AS fuel_type,
        tt.name AS transmission,
        bt.name AS body_type,
        manu.name AS manufacturer,
        mf.name AS model_family,
        m.name AS model_name,
        v.name AS variant_name,
        array_remove(array_agg(f.name ORDER BY f.name), NULL) AS features,
        l.created_at,
        l.updated_at
    FROM market.listings l
    JOIN pricing.cities AS cities ON cities.id = l.city_id
    JOIN catalog.variants AS v ON v.id = l.variant_id
    JOIN catalog.models AS m ON m.id = v.model_id
    JOIN catalog.model_families AS mf ON mf.id = m.model_family_id
    JOIN catalog.manufacturers AS manu ON manu.id = mf.manufacturer_id
    JOIN catalog.fuel_types ft ON ft.id = l.fuel_type_id
    JOIN catalog.transmission_types tt ON tt.id = l.transmission_type_id
    JOIN catalog.body_types bt ON bt.id = v.body_type_id
    LEFT JOIN catalog.variant_features vf ON vf.variant_id = v.id
    LEFT JOIN catalog.features f ON f.id = vf.feature_id
    GROUP BY l.id, cities.name, ft.name, tt.name, bt.name, manu.name, mf.name, m.name, v.name;
    """
    with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
        cur.execute(query)
        for row in cur.fetchall():
            title = " ".join(
                [
                    row["manufacturer"],
                    row["model_family"],
                    row["model_name"],
                    row["variant_name"],
                ]
            ).strip()
            description = f"{row['year'] or ''} {row['fuel_type']} {row['transmission']}".strip()
            yield {
                "_index": os.getenv("LISTINGS_SEARCH_INDEX", "listings_search"),
                "_id": str(row["id"]),
                "_source": {
                    "id": str(row["id"]),
                    "org_id": str(row["org_id"]),
                    "variant_id": str(row["variant_id"]),
                    "city_id": str(row["city_id"]),
                    "city": row["city"],
                    "listing_type": row["listing_type"],
                    "status": row["status"],
                    "price": float(row["price"]) if row["price"] is not None else None,
                    "year": row["year"],
                    "km": row["km"],
                    "fuel_type": row["fuel_type"],
                    "transmission": row["transmission"],
                    "body_type": row["body_type"],
                    "title": title,
                    "description": description,
                    "features": row["features"] or [],
                    "created_at": row["created_at"],
                    "updated_at": row["updated_at"],
                },
            }


def fetch_catalog_suggest(conn):
    with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
        cur.execute("SELECT id, name FROM catalog.manufacturers;")
        for row in cur.fetchall():
            yield {
                "_index": os.getenv("CATALOG_SUGGEST_INDEX", "catalog_suggest"),
                "_id": f"manufacturer-{row['id']}",
                "_source": {
                    "id": str(row["id"]),
                    "type": "manufacturer",
                    "name": row["name"],
                    "suggest": {"input": [row["name"]], "contexts": {"type": ["manufacturer"]}},
                },
            }

        cur.execute(
            """
            SELECT mf.id, mf.name, manu.name AS manufacturer
            FROM catalog.model_families mf
            JOIN catalog.manufacturers manu ON manu.id = mf.manufacturer_id;
            """
        )
        for row in cur.fetchall():
            label = f"{row['manufacturer']} {row['name']}"
            yield {
                "_index": os.getenv("CATALOG_SUGGEST_INDEX", "catalog_suggest"),
                "_id": f"family-{row['id']}",
                "_source": {
                    "id": str(row["id"]),
                    "type": "model_family",
                    "name": label,
                    "suggest": {"input": [label], "contexts": {"type": ["model_family"]}},
                },
            }

        cur.execute(
            """
            SELECT v.id, v.name, m.name AS model_name, mf.name AS family, manu.name AS manufacturer
            FROM catalog.variants v
            JOIN catalog.models m ON m.id = v.model_id
            JOIN catalog.model_families mf ON mf.id = m.model_family_id
            JOIN catalog.manufacturers manu ON manu.id = mf.manufacturer_id;
            """
        )
        for row in cur.fetchall():
            label = f"{row['manufacturer']} {row['family']} {row['model_name']} {row['name']}"
            yield {
                "_index": os.getenv("CATALOG_SUGGEST_INDEX", "catalog_suggest"),
                "_id": f"variant-{row['id']}",
                "_source": {
                    "id": str(row["id"]),
                    "type": "variant",
                    "name": label,
                    "suggest": {"input": [label], "contexts": {"type": ["variant"]}},
                },
            }


def main():
    listings_index = os.getenv("LISTINGS_SEARCH_INDEX", "listings_search")
    catalog_index = os.getenv("CATALOG_SUGGEST_INDEX", "catalog_suggest")
    client = opensearch_client()

    apply_index_template(client, "listings_search_template", "listings_search.json")
    apply_index_template(client, "catalog_suggest_template", "catalog_suggest.json")
    ensure_index(client, listings_index)
    ensure_index(client, catalog_index)

    with postgres_conn() as conn:
        listings = list(fetch_listings(conn))
        catalog = list(fetch_catalog_suggest(conn))

    actions = listings + catalog
    if not actions:
        print("No data to index (Postgres tables may be empty).", file=sys.stderr)
        return

    success, failed = helpers.bulk(client, actions, raise_on_error=False)
    print(f"Indexed {success} documents; failed: {len(failed)}")
    if failed:
        sys.exit(1)


if __name__ == "__main__":
    main()
